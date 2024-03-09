extends Object
class_name Util

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------
static func Is_Dict_Property_Type(d : Dictionary, p : String, t : int) -> bool:
	if not d.is_empty() and p in d:
		return typeof(d[p]) == t
	return false

static func Dict_Properties_Exist(d : Dictionary, props : Array, any_exist : bool = false) -> bool:
	if not d.is_empty():
		var found = false
		for p in props:
			if p.size() != 2 or typeof(p[0]) != TYPE_STRING or typeof(p[1]) != TYPE_INT:
				if any_exist: continue
				return false
			if p[0] in d and typeof(d[p[0]]) == p[1]:
				if any_exist: return true
				found = true
		return found
	return false

# ------------------------------------------------------------------------------
# Handler Methods
# ------------------------------------------------------------------------------



