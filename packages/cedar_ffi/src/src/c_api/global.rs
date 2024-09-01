use std::{collections::HashMap, ffi::c_char, ptr::null, str::FromStr};

use cedar_policy::{EntityUid, PolicyId, SlotId};

use super::helpers;

/// The result of parsing policies from a Cedar policy string into JSON
/// via [cedar_parse_policies].
#[derive(Debug)]
#[repr(C)]
pub struct CCedarPolicySetResult {
    /// The length of the `policy_set_json` string.
    policy_set_json_len: usize,

    /// The policy set in JSON format.
    ///
    /// This is only valid if `errors` is null.
    policy_set_json: *const c_char,

    /// The number of errors encountered while parsing the policy set.
    errors_len: usize,

    /// The errors (as strings) encountered while parsing the policy set.
    errors: *const *const c_char,
}

/// Parses a policy set from a Cedar policy string into JSON.
#[no_mangle]
pub extern "C" fn cedar_parse_policy_set(policies: *const c_char) -> CCedarPolicySetResult {
    helpers::log_on_error(
        || {
            anyhow::ensure!(!policies.is_null(), "policies is null");
            let policies = helpers::string_from_c("policies", policies)?;
            let (policy_set, errors) = match cedar_policy::PolicySet::from_str(policies) {
                Ok(policy_set) => (policy_set, vec![]),
                Err(e) => (cedar_policy::PolicySet::new(), e.0),
            };

            let policy_set_json = serde_json::to_string(&policy_set.to_json()?)?;
            let policy_set_json_len = policy_set_json.len();
            let policy_set_json = helpers::string_to_c(policy_set_json)?;

            let errors = errors
                .iter()
                .map(|e| helpers::string_to_c(e.to_string()))
                .collect::<Result<Vec<_>, _>>()?
                .to_owned();
            let errors_len = errors.len();
            let errors_ptr = errors.as_ptr();
            std::mem::forget(errors);

            Ok(CCedarPolicySetResult {
                policy_set_json_len,
                policy_set_json,
                errors_len,
                errors: errors_ptr,
            })
        },
        "parsing policies",
        |e| {
            let error_str = helpers::string_to_c(e.to_string()).unwrap();
            CCedarPolicySetResult {
                policy_set_json_len: 0,
                policy_set_json: null(),
                errors_len: 1,
                errors: &error_str,
            }
        },
    )
}

/// Links a policy template to a set of entities.
/// 
/// Returns the linked policy template in JSON format.
#[no_mangle]
pub extern "C" fn cedar_link_policy_template(
    policy_template_json: *const c_char,
    entities_json: *const c_char,
) -> *const c_char {
    helpers::log_on_error(
        || {
            let policy_template_json =
                helpers::string_from_c("policy_template_json", policy_template_json)?;
            let entities_json = helpers::string_from_c("entities_json", entities_json)?;

            let policy_template = cedar_policy::Template::from_json(
                Some(PolicyId::new("template")),
                serde_json::from_str(&policy_template_json)?,
            )?;
            let entities: HashMap<String, String> = serde_json::from_str(&entities_json)?;
            let entities: HashMap<SlotId, EntityUid> = entities
                .iter()
                .map(|(k, v)| {
                    Ok((
                        match k.as_str() {
                            "?principal" => SlotId::principal(),
                            "?resource" => SlotId::resource(),
                            _ => return Err(anyhow::anyhow!("invalid slot id")),
                        },
                        EntityUid::from_str(v)?,
                    ))
                })
                .collect::<anyhow::Result<_>>()?;

            let mut policy_set = cedar_policy::PolicySet::new();
            policy_set.add_template(policy_template)?;
            policy_set.link(PolicyId::new("template"), PolicyId::new("linked"), entities)?;

            let linked_policy = policy_set
                .policy(&PolicyId::new("linked"))
                .ok_or(anyhow::anyhow!("linked policy not found"))?;
            let linked_policy_template_json = serde_json::to_string(&linked_policy.to_json()?)?;
            let linked_policy_template_json = helpers::string_to_c(linked_policy_template_json)?;

            Ok(linked_policy_template_json)
        },
        "linking policy template",
        |_| null(),
    )
}
