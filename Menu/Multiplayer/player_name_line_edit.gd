extends LineEdit

signal sanitized_name_changed(new_name: String)


func _on_text_changed(new_text:String):
	var old_caret_position = self.caret_column

	var word = ''
	var regex = RegEx.new()
	regex.compile("[\\w\\s\\p{P}]")
	for sanitized_character in regex.search_all(new_text):
		word += sanitized_character.get_string()
	self.set_text(word)

	caret_column = old_caret_position

	sanitized_name_changed.emit(self.text)
