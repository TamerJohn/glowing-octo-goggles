class SessionPersistance
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end
  
  def find_list(id)
    @session[:lists].find{ |list| list[:id] == id }
  end
  
  def all_lists
    @session[:lists]
  end
  
  def delete_list(id)
    @session[:lists].reject! do |list|
      list[:id] == id
    end
  end
  
  def create_list(list_name)
    id = next_element_id(@session[:lists])
    @session[:lists] << { id: id, name: list_name, todos: [] }
  end
  
  def update_list_name(list_id, list_name)
    list = find_list(list_id)
    list[:name] = list_name
  end
  
  def create_new_todo(list_id, todo_name)
    list = find_list(list_id)
    id = next_element_id(list[:todos])
    
    list[:todos] << { id: id, name: todo_name, completed: false }
  end
  
  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    
    list[:todos].reject! { |todo| todo[:id] == todo_id }
  end
  
  def complete_todo(list_id, todo_id, completed)
    list = find_list(list_id)
    
    todo = list[:todos].find { |todo| todo[:id] == todo_id }
    todo[:completed] = completed
  end
  
  def mark_all_todos_completed(list_id)
    list = find_list(list_id)
    
    list[:todos].each do |todo|
      todo[:completed] = true
    end
  end
  private
    
  def next_element_id(elements)
    max = elements.map { |todo| todo[:id] }.max || 0
    max + 1
  end
end

def load_list(id)
  list = @storage.find_list(id)
  
  return list if list

  session[:error] = "The specified list was not found."
  redirect "/lists"
  halt
end
