/// MAIL POST CLASS 

function MailPost(instance_or_struct_is_persistant = false, inst_struct_reference = other) constructor {
	persistant = instance_or_struct_is_persistant;
	scope_reference = inst_struct_reference;
	mailpost_subscriptions = ds_list_create();
	
	/// @func add_subscription
	static add_subscription	= function(event, callback_function, data = undefined){ 
		var _sub_data = new __mailpost_subscription_data(event, callback_function, scope_reference, data, self);
		ds_list_add(mailpost_subscriptions, _sub_data);
		__mailpost_add_subscription_by_event(_sub_data);
		return self;
	}
	
	/// @func delete_subscription
	static delete_subscription = function(event){
		var _mailpost_data, _i = 0; 
		repeat(ds_list_size(mailpost_subscriptions)){
			_mailpost_data = mailpost_subscriptions[| _i++];
			if(_mailpost_data.__event == event){
				ds_queue_enqueue(global.__mp_remove_subscription_queue, _mailpost_data);	
				break;
			}
		}
	}
	
	/// @func delete_all_subscriptions
	static delete_all_subscriptions	= function(){
		var _mailpost_data, _i = 0; 
		repeat(ds_list_size(mailpost_subscriptions)){
			_mailpost_data = mailpost_subscriptions[| _i++];
			ds_queue_enqueue(global.__mp_remove_subscription_queue, _mailpost_data);	
		}
	}
	
	/// @func mail_clean_up
	static mail_clean_up = function(){
		var _index = ds_list_find_index(global.__mp_all_mailposts, self);
		if(_index >= 0) ds_list_delete(global.__mp_all_mailposts, _index);
		
		delete_all_subscriptions();
		ds_list_delete(mailpost_subscriptions);
	}
	
	static __clean_up_force = function(){
		delete_all_subscriptions();
		ds_list_delete(mailpost_subscriptions);
	}
	
	ds_list_add(global.__mp_all_mailposts, self);
}
