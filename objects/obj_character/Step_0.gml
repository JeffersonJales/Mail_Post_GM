/// @description 
switch(player_state){
	case PLAYER_STATE.IDLE:	
		player_moviment();
		player_set_sprite(Sprite_Player_idle);
		ignore_pause_event();
		break;
	
	case PLAYER_STATE.WALK:
		player_moviment();
		player_set_sprite(Sprite_Player_walk);
		ignore_pause_event();

		break;
	
	case PLAYER_STATE.WAITING_RESUME:	
		break;
}

