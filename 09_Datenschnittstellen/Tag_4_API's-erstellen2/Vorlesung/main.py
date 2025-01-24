from fastapi import FastAPI, status, HTTPException
from pydantic import BaseModel, Field
import uvicorn

app = FastAPI(
    title='August-Todos',
    summary='Eine API zum Verwalten von Todos'
)

todos = [
    dict(id=1, title='Müll rausbringen', status=False, priority=5),
    dict(id=2, title='Wäsche waschen', status=True, priority=2),
    dict(id=3, title='Geschirr spülen', status=False, priority=3),
    dict(id=4, title='Einkaufen', status=True, priority=3)
]

# Was zeichnet eine Todo aus?
# 1. Die Form
# 2. Die Wertebereiche

# id: int, eindeutig und ab 1 aufsteigend
# title: str, zwischen 3, 75 Zeichen
# status: bool
# priority: int, 1-5


# 1. Form
# class Todo(BaseModel):
#     id: int
#     title: str
#     status: bool
#     priority: int

# 2. Form + Wertebereiche:
class Todo(BaseModel):
    # Da wir nicht den Nutzer die IDs übergeben lassen wollen, sondern diese generiert werden sollen
    # Kommentieren wir id aus.
    # id: int = Field(gt=0)  # gt=greater than, ge=greater/equal, lt=less then, le=less/equal
    title: str = Field(min_length=3, max_length=66, default='Enter title')  # min_length (von Strings), max_length (von Strings)
    status: bool = Field(default=False)  # default > Standardwert (der soll False sein!); einfacher bool = False
    priority: int = Field(ge=1, le=5, default=3)


### GET-Requests

# Root-Ebene
@app.get('/', status_code=status.HTTP_200_OK, tags=['welcome'])
def greet_user():
    return {'message': 'Hallo CLient! Willkommen in deiner Todo-App!'}


# todos Endpoint
@app.get('/todos/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_all_todos():
    return todos


# todos mit Query Parameter priority
@app.get('/todos', status_code=status.HTTP_200_OK, tags=['get data'])
def filter_by_priority(priority: int):
    to_return = []
    for todo in todos:
        if todo['priority'] == priority:
            to_return.append(todo)

    if to_return:
        return to_return

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f'Keine Todos der Priorität {priority} gefunden.')


# Pfad mit Pfadparameter {x}
@app.get('/todos/{todo_id}/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_todo(todo_id: int) -> dict:
    for todo in todos:
        if todo['id'] == todo_id:
            return todo

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f'Keine Todo mit der ID {todo_id} vorhanden.')


# Endpoint unfinished
@app.get('/todos/unfinished/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_unfinished_todos():
    to_return = []
    for todo in todos:
        if not todo['status']:  # Prüft, ob an der Stelle ein False steht. Analog: if todo['status'] == False.
            to_return.append(todo)

    if to_return:
        return to_return

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail='Keine offenen Todos.')


# Endpoint finished
@app.get('/todos/finished/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_finished_todos():
    to_return = []
    for todo in todos:
        if todo['status']:  # Prüft, ob an der Stelle ein True steht. Analog: if todo['status'] == True.
            to_return.append(todo)

    if to_return:
        return to_return

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail='Du faules Stück, es ist noch nichts erledigt!')


### POST-Request

@app.post('/todos/', status_code=status.HTTP_201_CREATED, tags=['controller'])
def post_todo(todo: Todo):
    max_id = todos[-1]['id']
    todo_dict = todo.model_dump()  # ehemals .dict() (deprecated)
    todo_dict['id'] = max_id + 1
    todos.append(todo_dict)


### PATCH-Request


@app.patch('/todos/update', status_code=status.HTTP_204_NO_CONTENT, tags=['controller'])
def update_status(todo_id: int):
    changed = False
    for todo in todos:
        if todo['id'] == todo_id:
            todo['status'] = not todo['status']
            new_status = todo['status']
            changed = True

    if changed:
        return {'message': f'Status der Todo mit ID {todo_id} ist auf {new_status} gesetzt.'}

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f'Keine Todo mit der ID {todo_id} vorhanden.')



### DELETE REQUEST
# Method not allowed in bestimmten Fällen?

@app.delete('/todos/delete/{todo_id}/', status_code=status.HTTP_204_NO_CONTENT, tags=['controller'])
def delete_todo(todo_id: int):
    for todo in todos:
        if todo['id'] == todo_id:
            todos.remove(todo)
            return {'message': 'Todo entfernt!'}

    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND,
                        detail=f'Keine Todo mit der ID {todo_id} vorhanden.')


if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000)
