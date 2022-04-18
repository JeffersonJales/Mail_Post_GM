/// Making event driven more easy to use
/// Getting the best about DoLater and Observer Pattern from Juju and FriendlyCosmonault

#macro MAILPOST_SAFE_CALLBACK_EXECUTION true
#macro DELETE_SUBSCRIPTION_CASE_CANT_FIND_MAILPOST true
#macro MAILPOST_CLASS_NAME "MailPost"

global.__mp_all_mailposts = ds_list_create(); 
global.__mp_subscriptions_by_event = ds_map_create(); // KEY (EVENT) : DS_LIST : __mailpost_listener_data
global.__mp_remove_subscription_queue = ds_queue_create(); 

function MailPost(instance_or_struct_is_persistant = false, inst_struct_reference = other) constructor {
	persistant = instance_or_struct_is_persistant;
	scope_reference = inst_struct_reference;
	scope_weak_ref = weak_ref_create(inst_struct_reference);
	
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
				__mailpost_enqueue_delete_subscriber(_mailpost_data);
				break;
			}
		}
		
		return self;
	}
	
	/// @func delete_all_subscriptions
	static delete_all_subscriptions	= function(){
		var _i = 0; 
		repeat(ds_list_size(mailpost_subscriptions)){
			__mailpost_enqueue_delete_subscriber(mailpost_subscriptions[| _i++]);
		}
	}
	
	static __clean_up_force = function(){
		delete_all_subscriptions();
		ds_list_destroy(mailpost_subscriptions);
	}
	
	ds_list_add(global.__mp_all_mailposts, self);
}

function mailpost_delivery(event, broadcast_data = undefined){
	__mailpost_force_delete_queue();
	
	var _subscribers = global.__mp_subscriptions_by_event[? event];
	if(_subscribers == undefined) return;
	
	var _subscription_data,
		_i = 0; 
	
	repeat(ds_list_size(_subscribers)){
		var _return_data = false;
		
		_subscription_data = _subscribers[| _i++];

		if(MAILPOST_SAFE_CALLBACK_EXECUTION){
			if(weak_ref_alive(_subscription_data.__mailpost_reference.scope_weak_ref))
				_return_data = _subscription_data.__callback(broadcast_data, _subscription_data.__data);
			else 
				_return_data = DELETE_SUBSCRIPTION_CASE_CANT_FIND_MAILPOST;
		}
		else{
			_return_data = _subscription_data.__callback(broadcast_data, _subscription_data.__data);
		}
		
		if(_return_data == true) 
			__mailpost_enqueue_delete_subscriber(_subscription_data);
	}
}

function mailpost_clean_all_but_persistant(){
	var _mailpost, _i = 0; 
	repeat(ds_list_size(global.__mp_all_mailposts)){
		_mailpost = global.__mp_all_mailposts[| _i];
		
		if(!_mailpost.persistant){
			_mailpost.__clean_up_force();
			ds_list_delete(global.__mp_all_mailposts, _i);
		}
		else
			_i++;
	}
	
	__mailpost_force_delete_queue();
}

function mailpost_clean_all(){

	var _mailpost;
	repeat(ds_list_size(global.__mp_all_mailposts)){
		_mailpost = global.__mp_all_mailposts[| 0];
		_mailpost.__clean_up_force();
		delete _mailpost;
		ds_list_delete(global.__mp_all_mailposts, 0);
	}
	
	__mailpost_force_delete_queue();

	
	var _arr = ds_map_keys_to_array(global.__mp_subscriptions_by_event),
		_i = 0,
		_list;
	
	repeat(array_length(_arr)){
		_list = global.__mp_subscriptions_by_event[? _arr[_i++]];
		ds_list_destroy(_list);
	}
	
	ds_map_clear(global.__mp_subscriptions_by_event);

} 

/// @desc With this function you will delete the content of the mailpost object 
/// @param {Struct.MailPost} mailpost_object	The mailpost struct reference
function mainpost_delete(mailpost_object){
	if(instanceof(mailpost_object) != MAILPOST_CLASS_NAME) return;
	
	mailpost_object.__clean_up_force();
	ds_list_delete_search(global.__mp_all_mailposts, mailpost_object);
}

/// INNER USAGE
function __mailpost_subscription_data (event, callback_function, scope_reference, data, mailpost_reference) constructor{
	__data = data;
	__event = event;
	__callback = method(scope_reference, callback_function);
	__mailpost_reference = mailpost_reference;
}

function __mailpost_add_subscription_by_event(subscription_data){
	var _list = global.__mp_subscriptions_by_event[? subscription_data.__event];
	if(_list == undefined) {
		_list = ds_list_create();
		global.__mp_subscriptions_by_event[? subscription_data.__event] = _list;
	}
	ds_list_add(_list, subscription_data);
}

function __mailpost_enqueue_delete_subscriber(maildata){
	ds_queue_enqueue(global.__mp_remove_subscription_queue, maildata);	
}

function __mailpost_force_delete_queue(){
	var _mailpost_data = ds_queue_dequeue(global.__mp_remove_subscription_queue);
	while(_mailpost_data != undefined){
		
		var _list = global.__mp_subscriptions_by_event[? _mailpost_data.__event];
		if(_list != undefined) ds_list_delete_search(_list, _mailpost_data);
		
		var _mailpost = _mailpost_data.__mailpost_reference;
		ds_list_delete_search(_mailpost.mailpost_subscriptions, _mailpost_data);
		
		delete _mailpost_data;
		_mailpost_data = ds_queue_dequeue(global.__mp_remove_subscription_queue);
	}
}

