## Helper class to define and provide relative coordinate offsets for card shapes.
class_name ShapeDefinitions extends RefCounted # Use RefCounted as it's just data/static methods


# --- Relative Offset Definitions (centered at 0,0) ---

const O_OFFSETS :Array[Vector2i]= [
	Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
	Vector2i(-1, 0), Vector2i(1, 0),
	Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1)
]

const PLUS_OFFSETS :Array[Vector2i]= [
					Vector2i(0, -1),
	Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0),
					Vector2i(0, 1)
]

const XLINE_OFFSETS :Array[Vector2i]= [
	Vector2i(-1, 0), Vector2i(0, 0), Vector2i(1, 0)
]

const YLINE_OFFSETS :Array[Vector2i]= [
	Vector2i(0, -1), Vector2i(0, 0), Vector2i(0, 1)
]

const XSHAPE_OFFSETS :Array[Vector2i]= [
	Vector2i(-1, -1), Vector2i(1, -1),
					Vector2i(0, 0),
	Vector2i(-1, 1), Vector2i(1, 1)
]

const DOT_OFFSETS :Array[Vector2i]= [
	Vector2i(0,0)
]


## Static function to retrieve the relative offsets for a given shape.
static func get_offsets(shape: CardData.Shape) -> Array[Vector2i]:
	match shape:
		CardData.Shape.O:
			return O_OFFSETS
		CardData.Shape.PLUS:
			return PLUS_OFFSETS
		CardData.Shape.XLine:
			return XLINE_OFFSETS
		CardData.Shape.YLine:
			return YLINE_OFFSETS
		CardData.Shape.XShape:
			return XSHAPE_OFFSETS
		CardData.Shape.DOT:
			return DOT_OFFSETS
		_:
			push_warning("ShapeDefinitions.get_offsets: Unknown shape provided: %s" % CardData.Shape.keys()[shape])
			return [] # Return empty for unknown shapes
