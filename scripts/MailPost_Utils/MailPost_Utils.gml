function ds_list_delete_search(list, value){
	var pos = ds_list_find_index(list, value);
	if(pos >= 0) ds_list_delete(list, pos);
}