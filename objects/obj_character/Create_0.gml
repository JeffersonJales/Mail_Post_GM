/// @description 

/// OBJECT CREATE EVENT EXAMPLE
pause_game_function = function(broadcast_data, data){}
resume_game_function = function(broadcast_data){}

my_mailpost = new MailPost();
my_mailpost
.add_subscription(GAME_EVENT.PAUSE, pause_game_function, 42)
.add_subscription(GAME_EVENT.RESUME, resume_game_function);

/// CLEAN UP EVENT
my_mailpost.clean_up();

/// ROOM END EVENT
mailpost_clean_all_but_persistant();

