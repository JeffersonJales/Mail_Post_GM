/// @description PAUSE GAME
if(keyboard_check_pressed(vk_enter)){
	if(!pause) mailpost_delivery(GAME_EVENT.PAUSE);
	else mailpost_delivery(GAME_EVENT.RESUME)
	
	pause = !pause;
}
