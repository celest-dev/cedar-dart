use cedar_policy::{AuthorizationError, Entities, EntityUid, PolicySet, Schema};
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
    /// Can be `null` to indicate an anonymous principal.
    principal_str: *const c_char,

    /// The resource to check authorization for, in entity UID format.
    ///
    /// Can be `null` to indicate an anonymous resource.
    resource_str: *const c_char,

    /// The action to check authorization for, in entity UID format.
    ///
    /// Can be `null` to indicate an anonymous action.
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
#[no_mangle]
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
#[no_mangle]
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
#[no_mangle]
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

    let principal_id = match principal {
        Some(principal) => Some(EntityUid::from_str(principal)?),
        None => None,
    };
    let resource_id = match resource {
        Some(resource) => Some(EntityUid::from_str(resource)?),
        None => None,
    };
    let action_id = match action {
        Some(action) => Some(EntityUid::from_str(action)?),
        None => None,
    };
    let context = match context_json {
        Some(context_json) => Some(cedar_policy::Context::from_json_str(
            context_json,
            action_id.as_ref().map(|a| (&store.schema, a)),
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
        .map(|e| {
            serde_json::json!({
                "policy_id": e.id().to_string(),
                "message": match e {
                    AuthorizationError::PolicyEvaluationError { error, .. } => error.to_string(),
                },
            })
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
