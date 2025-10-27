use cedar_policy::{
    AuthorizationError, Entities, EntityId, EntityTypeName, EntityUid, PolicySet, Schema,
};
use std::{
    ffi::c_char,
    ptr::{null, null_mut},
    str::FromStr,
};

use super::helpers;
use crate::CedarStore;

#[derive(Debug)]
#[repr(C)]
pub struct CCedarConfig {
    /// The Cedar schema, in JSON format.
    ///
    /// Either this or `schema_idl` must be provided.
    schema_json: *const c_char,

    /// The Cedar schema, in IDL format.
    ///
    /// Either this or `schema_json` must be provided.
    schema_idl: *const c_char,

    /// The Cedar entities, in JSON format.
    ///
    /// Can be `null` to indicate no entities. Entities can be passed individually to [cedar_is_authorized].
    entities_json: *const c_char,

    /// The Cedar policies, in JSON format.
    ///
    /// Can be `null` to indicate no policies. Policies can be passed individually to [cedar_is_authorized].
    policies_json: *const c_char,

    /// Whether to validate the Cedar policies.
    validate: bool,

    /// The log level to use for the Cedar policy engine.
    ///
    /// Must be one of: `OFF`, `ERROR`, `WARN`, `INFO`, `DEBUG`, `TRACE`.
    log_level: *const c_char,
}

#[repr(C)]
pub struct CCedarQuery {
    /// The principal to check authorization for, in entity UID format.
    ///
    /// Must not be `null`.
    principal_str: *const c_char,

    /// The resource to check authorization for, in entity UID format.
    ///
    /// Must not be `null`.
    resource_str: *const c_char,

    /// The action to check authorization for, in entity UID format.
    ///
    /// Must not be `null`.
    action_str: *const c_char,

    /// The check's context, if any, in JSON format.
    ///
    /// Can be `null` to indicate no context.
    context_json: *const c_char,

    /// The Cedar entities, in JSON format.
    ///
    /// Can be `null` to use the existing entities.
    entities_json: *const c_char,

    /// The Cedar policies, in JSON format.
    ///
    /// Can be `null` to use the existing policies.
    policies_json: *const c_char,
}

/// The result of initializing the Cedar policy engine via [cedar_init].
#[repr(C)]
pub struct CInitResult {
    /// Whether the operation succeeded.
    store: *mut CedarStore,

    /// The error message, if any.
    ///
    /// Can be `null` to indicate no error.
    error: *const c_char,

    /// The length of `error`, if present.
    error_len: usize,
}

#[derive(Debug)]
#[repr(C)]
pub struct CAuthorizationDecision {
    /// Whether the request is authorized.
    is_authorized: bool,

    /// The error message, if any.
    ///
    /// If set, the authorization decision could not be made and no other
    /// fields should be used.
    completion_error: *const c_char,

    /// The length of `completion_error`, if present.
    completion_error_len: usize,

    /// The JSON array of reasons.
    ///
    /// Type: `[]string`
    ///
    /// Each entry is a policy ID which contributed to the decision.
    ///
    /// Will be `null` if there are no reasons.
    reasons_json: *const c_char,

    /// The length of `reasons_json`, if present.
    reasons_json_len: usize,

    /// The JSON array of errors.
    ///
    /// Type: `[]{ "policy_id": string, "message": string }`
    ///
    /// Each entry is an error that occurred during policy evaluation.
    ///
    /// Will be `null` if there are no errors.
    errors_json: *const c_char,

    /// The length of `errors_json`, if present.
    errors_json_len: usize,
}

/// Initializes the Cedar policy engine with the given configuration.
///
/// This must be called exactly once before any other Cedar functions are called.
#[unsafe(no_mangle)]
pub extern "C" fn cedar_init(config: *const CCedarConfig) -> CInitResult {
    match init_from_c_config(config) {
        Ok(store) => CInitResult {
            store,
            error: null(),
            error_len: 0,
        },
        Err(error) => {
            let error = error.to_string();
            let error_len = error.len();
            let cerror = helpers::string_to_c(error).unwrap();
            CInitResult {
                store: null_mut(),
                error: cerror,
                error_len,
            }
        }
    }
}

/// De-initializes the Cedar policy engine.
///
/// This must be called exactly once when the Cedar policy engine is no longer needed.
#[unsafe(no_mangle)]
pub extern "C" fn cedar_deinit(store: *mut CedarStore) {
    helpers::log_on_error(
        || {
            anyhow::ensure!(!store.is_null(), "store is null");
            let _ = unsafe { Box::from_raw(store) };
            Ok(())
        },
        "deinitializing cedar",
        |_| (),
    )
}

/// Performs a Cedar authorization check.
///
/// This must be called after [cedar_init] has been called.
#[unsafe(no_mangle)]
pub extern "C" fn cedar_is_authorized(
    store: *mut CedarStore,
    query: *const CCedarQuery,
) -> CAuthorizationDecision {
    match _cedar_is_authorized(store, query) {
        Ok(decision) => decision,
        Err(error) => {
            let error = error.to_string();
            let error_len = error.len();
            let error_str = helpers::string_to_c(error).unwrap();
            CAuthorizationDecision {
                is_authorized: false,
                completion_error: error_str,
                completion_error_len: error_len,
                reasons_json: null(),
                reasons_json_len: 0,
                errors_json: null(),
                errors_json_len: 0,
            }
        }
    }
}

fn _cedar_is_authorized(
    store: *mut CedarStore,
    query: *const CCedarQuery,
) -> anyhow::Result<CAuthorizationDecision> {
    anyhow::ensure!(!store.is_null(), "store is null");
    anyhow::ensure!(!query.is_null(), "query is null");
    let store = unsafe { &*store };
    let query = unsafe { &*query };

    let principal = helpers::nullable_string_from_c(query.principal_str)?;
    let resource = helpers::nullable_string_from_c(query.resource_str)?;
    let action = helpers::nullable_string_from_c(query.action_str)?;
    let context_json = helpers::nullable_string_from_c(query.context_json)?;
    let entities_json = helpers::nullable_string_from_c(query.entities_json)?;
    let policies_json = helpers::nullable_string_from_c(query.policies_json)?;

    log::trace!(
        "_cedar_is_authorized(principal={:?}, resource={:?}, action={:?}, context={:?})",
        principal,
        resource,
        action,
        context_json,
    );

    let principal_id = match principal.as_deref() {
        Some(principal) => parse_normalized_entity_uid(principal, "principal")?,
        None => anyhow::bail!("principal is required"),
    };
    let resource_id = match resource.as_deref() {
        Some(resource) => parse_normalized_entity_uid(resource, "resource")?,
        None => anyhow::bail!("resource is required"),
    };
    let action_id = match action.as_deref() {
        Some(action) => parse_normalized_entity_uid(action, "action")?,
        None => anyhow::bail!("action is required"),
    };
    let context = match context_json {
        Some(context_json) => Some(cedar_policy::Context::from_json_str(
            context_json,
            Some((&store.schema, &action_id)),
        )?),
        None => None,
    };
    let entities = match entities_json {
        Some(entities_json) => Some(Entities::from_json_str(entities_json, Some(&store.schema))?),
        None => None,
    };
    let policies = match policies_json {
        Some(policies_json_str) => Some(PolicySet::from_json_str(policies_json_str)?),
        None => None,
    };
    let response = store.is_authorized(
        principal_id,
        resource_id,
        action_id,
        context,
        policies.as_ref(),
        entities.as_ref(),
    )?;
    let errors = response
        .diagnostics()
        .errors()
        .map(|error| match error {
            AuthorizationError::PolicyEvaluationError(inner) => serde_json::json!({
                "policy_id": inner.policy_id().to_string(),
                "message": inner.inner().to_string(),
            }),
        })
        .collect::<Vec<_>>()
        .to_owned();
    let errors_json = serde_json::to_string(&errors)?;
    let errors_json_len = errors_json.len();
    let errors_json = helpers::string_to_c(errors_json)?;

    let reasons = response
        .diagnostics()
        .reason()
        .map(|r| r.to_string())
        .collect::<Vec<_>>()
        .to_owned();
    let reasons_json = serde_json::to_string(&reasons)?;
    let reasons_json_len = reasons_json.len();
    let reasons_json = helpers::string_to_c(reasons_json)?;

    let c_response = CAuthorizationDecision {
        is_authorized: match response.decision() {
            cedar_policy::Decision::Allow => true,
            cedar_policy::Decision::Deny => false,
        },
        completion_error: null(),
        completion_error_len: 0,
        errors_json,
        errors_json_len,
        reasons_json,
        reasons_json_len,
    };
    Ok(c_response)
}

fn parse_normalized_entity_uid(value: &str, category: &str) -> anyhow::Result<EntityUid> {
    let (type_part, id_part) = split_normalized_entity_uid(value).ok_or_else(|| {
        anyhow::anyhow!("failed to parse {category} '{value}': missing '::\"' boundary")
    })?;

    anyhow::ensure!(
        !type_part.is_empty(),
        "failed to parse {category} '{value}': entity type is empty"
    );

    let type_name = EntityTypeName::from_str(type_part).map_err(|err| {
        anyhow::anyhow!(
            "failed to parse {category} '{value}': invalid type '{type_part}': {err:?}"
        )
    })?;

    anyhow::ensure!(
        id_part.starts_with('"') && id_part.ends_with('"'),
        "failed to parse {category} '{value}': entity id must be quoted"
    );
    let id_body = &id_part[1..id_part.len() - 1];
    let decoded_id = decode_normalized_entity_id(id_body).map_err(|err| {
        anyhow::anyhow!(
            "failed to parse {category} '{value}': invalid entity id escape: {err}"
        )
    })?;
    let entity_id = EntityId::from_str(&decoded_id).expect("EntityId::from_str is infallible");

    Ok(EntityUid::from_type_name_and_id(type_name, entity_id))
}

fn decode_normalized_entity_id(input: &str) -> anyhow::Result<String> {
    let mut output = String::with_capacity(input.len());
    let mut chars = input.chars().peekable();
    while let Some(ch) = chars.next() {
        if ch != '\\' {
            output.push(ch);
            continue;
        }

        let next = chars.next().ok_or_else(|| anyhow::anyhow!("dangling escape"))?;
        match next {
            '0' => output.push('\0'),
            't' => output.push('\t'),
            'n' => output.push('\n'),
            'r' => output.push('\r'),
            '\\' => output.push('\\'),
            '"' => output.push('"'),
            '\'' => output.push('\''),
            'u' => {
                anyhow::ensure!(
                    matches!(chars.next(), Some('{')),
                    "missing '{{' in unicode escape"
                );
                let mut hex = String::new();
                while let Some(&c) = chars.peek() {
                    if c == '}' {
                        chars.next();
                        break;
                    }
                    hex.push(c);
                    chars.next();
                }
                anyhow::ensure!(!hex.is_empty(), "empty unicode escape");
                let code_point = u32::from_str_radix(&hex, 16)
                    .map_err(|err| anyhow::anyhow!("invalid unicode escape: {err}"))?;
                let decoded = char::from_u32(code_point)
                    .ok_or_else(|| anyhow::anyhow!("invalid unicode code point: {code_point}"))?;
                output.push(decoded);
            }
            other => {
                anyhow::bail!("unsupported escape sequence \\{other}");
            }
        }
    }
    Ok(output)
}

fn split_normalized_entity_uid(value: &str) -> Option<(&str, &str)> {
    let boundary = value.find("::\"")?;
    let type_part = &value[..boundary];
    let id_part = &value[boundary + 2..];
    Some((type_part, id_part))
}

/// Initializes the Cedar policy engine with the given C configuration.
fn init_from_c_config(config: *const CCedarConfig) -> anyhow::Result<*mut CedarStore> {
    anyhow::ensure!(!config.is_null(), "config is null");
    let config = unsafe { &*config };

    let log_level = helpers::string_from_c("log_level", config.log_level)?;
    if !log_level.eq_ignore_ascii_case("OFF") {
        helpers::init_logging(log::Level::from_str(log_level)?);
    }

    let schema_json = helpers::nullable_string_from_c(config.schema_json)?;
    let schema_idl = helpers::nullable_string_from_c(config.schema_idl)?;
    anyhow::ensure!(
        schema_json.is_some() || schema_idl.is_some(),
        "either schema_json or schema_idl is required"
    );
    let schema = match schema_json {
        Some(schema_json) => Schema::from_json_value(serde_json::from_str(schema_json)?)?,
        None => Schema::from_str(schema_idl.unwrap())?,
    };

    let entities_json = helpers::nullable_string_from_c(config.entities_json)?;
    let entities = match entities_json {
        Some(entities_json) => Entities::from_json_str(entities_json, Some(&schema))?,
        None => Entities::empty(),
    };

    let policies_json = helpers::nullable_string_from_c(config.policies_json)?;
    let policies = match policies_json {
        Some(policies_json_str) => PolicySet::from_json_str(policies_json_str)?,
        None => PolicySet::new(),
    };

    let store = CedarStore::new(schema, entities, policies, config.validate)?;
    let store_ptr = Box::into_raw(Box::new(store));
    Ok(store_ptr)
}
