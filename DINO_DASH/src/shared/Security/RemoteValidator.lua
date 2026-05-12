--!strict

local RemoteValidator = {}

type PrimitiveType = "string" | "number" | "boolean" | "table" | "Instance" | "Vector3" | "CFrame"

export type FieldRule = {
	type: PrimitiveType,
	required: boolean?,
	min: number?,
	max: number?,
	maxLength: number?,
}

export type Schema = { [string]: FieldRule }

local function typeOf(value: any): string
	return typeof(value)
end

function RemoteValidator.validateTable(payload: any, schema: Schema): (boolean, string?)
	if typeOf(payload) ~= "table" then
		return false, "payload must be a table"
	end

	for fieldName, rule in pairs(schema) do
		local value = payload[fieldName]
		if value == nil then
			if rule.required == true then
				return false, `{fieldName} is required`
			end
			continue
		end

		if typeOf(value) ~= rule.type then
			return false, `{fieldName} must be {rule.type}`
		end

		if rule.type == "number" then
			local numberValue = value :: number
			if rule.min ~= nil and numberValue < rule.min then
				return false, `{fieldName} is below minimum`
			end
			if rule.max ~= nil and numberValue > rule.max then
				return false, `{fieldName} is above maximum`
			end
		elseif rule.type == "string" then
			local stringValue = value :: string
			if rule.maxLength ~= nil and #stringValue > rule.maxLength then
				return false, `{fieldName} is too long`
			end
		end
	end

	return true, nil
end

return RemoteValidator
