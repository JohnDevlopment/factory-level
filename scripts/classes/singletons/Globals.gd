extends Node

enum CollisionLayers {
	WALLS,
	PLATFORMS,
	PLAYER,
	OBJECTS,
	ENEMIES,
	PLAYER_HITBOX,
	PLAYER_HURTBOX,
	ENEMY_HITBOX,
	ENEMY_HURTBOX
}

var player_hurt_method := "hurt"
