from fastapi import FastAPI, status

app = FastAPI()


todos = [
    dict(id=1, title='Müll rausbringen', status=False, priority=5),
    dict(id=2, title='Wäsche waschen', status=True, priority=2),
    dict(id=3, title='Geschirr spülen', status=False, priority=3),
    dict(id=4, title='Einkaufen', status=True, priority=3)
]

@app.get('/', status_code=status.HTTP_200_OK)  # Root-Ebene
def greet_user():
    return {'message': 'Hallo CLient! Willkommen in deiner Todo-App!'}


@app.get('/todos/', status_code=status.HTTP_200_OK)
def get_all_todos():
    return todos


@app.get('/todos', status_code=status.HTTP_200_OK)
def filter_by_priority(priority: int):
    to_return = []
    for todo in todos:
        if todo['priority'] == priority:
            to_return.append(todo)

    if to_return:
        return to_return

    return {'message': f'Keine Todos der Priorität {priority} gefunden'}


@app.get('/todos/{todo_id}/', status_code=status.HTTP_200_OK)
def get_todo(todo_id: int) -> dict:
    for todo in todos:
        if todo['id'] == todo_id:
            return todo
    # 500?
    return {'message': f'Keine Todo mit der ID {todo_id} vorhanden.'}


@app.get('/todos/unfinished/', status_code=status.HTTP_200_OK)
def get_unfinished_todos():
    to_return = []
    for todo in todos:
        if not todo['status']:  # Prüft, ob an der Stelle ein False steht. Analog: if todo['status'] == False.
            to_return.append(todo)

    if to_return:
        return to_return

    return {'message': 'Keine offenen Todos.'}


@app.get('/todos/finished/', status_code=status.HTTP_200_OK)
def get_finished_todos():
    to_return = []
    for todo in todos:
        if todo['status']:  # Prüft, ob an der Stelle ein True steht. Analog: if todo['status'] == True.
            to_return.append(todo)

    if to_return:
        return to_return

    return {'message': 'Du faules Stück, es ist noch nichts erledigt!'}


@app.post('/todos/', status_code=status.HTTP_201_CREATED)
def post_todo(todo: dict):
    todos.append(todo)


@app.patch('/todos/update', status_code=status.HTTP_204_NO_CONTENT)
def update_status(todo_id: int):
    changed = False
    for todo in todos:
        if todo['id'] == todo_id:
            todo['status'] = not todo['status']
            new_status = todo['status']
            changed = True

    if changed:
        return {'message': f'Status der Todo mit ID {todo_id} ist auf {new_status} gesetzt.'}

    return {'message': f'Keine Todo mit ID {todo_id} gefunden.'}


# delete hinzufügen