class_name UniversalEndpointPolicy
extends RefCounted

var connectivity: LayoutAreaSemantics.Connectivity
var route_selection: LayoutAreaSemantics.RouteSelection
var minimum_endpoint_footprints: Array[Vector2i]
var undersized_endpoint_policy: LayoutAreaSemantics.UndersizedEndpointPolicy
var endpoint_assignment: LayoutAreaSemantics.EndpointAssignment
var equal_endpoint_policy: LayoutAreaSemantics.EqualEndpointPolicy


func _init(
	policy_connectivity: LayoutAreaSemantics.Connectivity,
	policy_route_selection: LayoutAreaSemantics.RouteSelection,
	policy_minimum_endpoint_footprints: Array[Vector2i],
	policy_undersized_endpoint_policy: LayoutAreaSemantics.UndersizedEndpointPolicy,
	policy_endpoint_assignment: LayoutAreaSemantics.EndpointAssignment,
	policy_equal_endpoint_policy: LayoutAreaSemantics.EqualEndpointPolicy
) -> void:
	connectivity = policy_connectivity
	route_selection = policy_route_selection
	minimum_endpoint_footprints = policy_minimum_endpoint_footprints.duplicate()
	undersized_endpoint_policy = policy_undersized_endpoint_policy
	endpoint_assignment = policy_endpoint_assignment
	equal_endpoint_policy = policy_equal_endpoint_policy


func duplicate_policy() -> UniversalEndpointPolicy:
	return UniversalEndpointPolicy.new(
		connectivity,
		route_selection,
		minimum_endpoint_footprints,
		undersized_endpoint_policy,
		endpoint_assignment,
		equal_endpoint_policy
	)
