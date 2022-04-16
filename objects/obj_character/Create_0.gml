/// @description 
enum PLAYER_STATE { IDLE, WALK, WAITING_RESUME }

#region SETUP A SIMPLE STATE MACHINE - USE SNOW STATE INSTEAD

player_state = PLAYER_STATE.IDLE;
player_last_state = PLAYER_STATE.IDLE;
player_speed = 1.5;

player_set_sprite = function(sprite){
	if(sprite_index != sprite){
		sprite_index = sprite;
		image_index = 0;
	}
}

player_moviment = function(){
	var _hori = keyboard_check(vk_right) - keyboard_check(vk_left);
	var _vert = keyboard_check(vk_down) - keyboard_check(vk_up);
	
	x += _hori * player_speed;
	y += _vert * player_speed;
	
	if(_hori != 0 || _vert != 0) 
		player_state = PLAYER_STATE.WALK;
	else
		player_state = PLAYER_STATE.IDLE;
}

#endregion

pause_game_function = function(){ 
	sprite_index = Sprite_Player_pause;
	player_last_state = player_state;
	player_state = PLAYER_STATE.WAITING_RESUME;
}
resume_game_function = function(){
	player_state = player_last_state;
}

listening = true;
ignore_pause_event = function(){
	if(keyboard_check_pressed(vk_space)){
		if(listening)
			my_mailpost.delete_all_subscriptions();
	
		else{
			my_mailpost
			.add_subscription(GAME_EVENT.PAUSE, pause_game_function)
			.add_subscription(GAME_EVENT.RESUME, resume_game_function);
		}
		listening = !listening;
	}
}

my_mailpost = new MailPost();
my_mailpost
.add_subscription(GAME_EVENT.PAUSE, pause_game_function)
.add_subscription(GAME_EVENT.RESUME, resume_game_function);


