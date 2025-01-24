import sqlite3
from fastapi import FastAPI, status, HTTPException, Depends
from pydantic import BaseModel, Field
import uvicorn


### Todos für die Todos (die wir zeitlich nicht geschafft haben):
#  1. Database Error Handling (try & except)
#  2. Automatische Datenbankerstellung (mit Tabelle!), wenn noch keine DB vorhanden.
#  3. Docstrings schreiben!
#  4. Refactoring (Modularisierung)

app = FastAPI(
    title='August-Todos',
    summary='Eine API zum Verwalten von Todos'
)


class Todo(BaseModel):
    # Da wir nicht den Nutzer die IDs übergeben lassen wollen, sondern diese generiert werden sollen
    # Kommentieren wir id aus.
    # id: int = Field(gt=0)  # gt=greater than, ge=greater/equal, lt=less then, le=less/equal
    title: str = Field(min_length=3, max_length=66,
                       default='Enter title')  # min_length (von Strings), max_length (von Strings)
    status: bool = Field(default=False)  # default > Standardwert (der soll False sein!); einfacher bool = False
    priority: int = Field(ge=1, le=5, default=3)


def get_connection():
    return sqlite3.connect('todos.sqlite')


### GET-Requests

# Root-Ebene
@app.get('/', status_code=status.HTTP_200_OK, tags=['welcome'])
def greet_user():
    return {'message': 'Hallo CLient! Willkommen in deiner Todo-App!'}


# todos Endpoint
@app.get('/todos/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_all_todos(conn=Depends(get_connection)):
    select_query = 'SELECT * FROM todos;'
    cursor = conn.cursor()
    cursor.execute(select_query)
    todos = cursor.fetchall()
    # todo[0] > id, todo[1] > title, todo[2] > status, todo[3] > priority
    todos_dicts = []

    for todo in todos:
        todo_dict = {'id': todo[0], 'title': todo[1], 'status': todo[2], 'priority': todo[3]}
        todos_dicts.append(todo_dict)
    #   Alternativ in einer Zeile mit dict-Constructor:
    #   todos = [dict(id=todo[0], title=todo[1], status=todo[2], priority=todo[3]) for todo in todos]

    return todos_dicts


# todos mit Query Parameter priority
@app.get('/todos', status_code=status.HTTP_200_OK, tags=['get data'])
def filter_by_priority(priority: int, conn=Depends(get_connection)):
    filter_query = 'SELECT * FROM todos WHERE priority = ?;'
    tupel = (priority,)
    cursor = conn.cursor()
    cursor.execute(filter_query, tupel)
    todos = cursor.fetchall()

    todos_dicts = []

    for todo in todos:
        todo_dict = {'id': todo[0], 'title': todo[1], 'status': todo[2], 'priority': todo[3]}
        todos_dicts.append(todo_dict)
    return todos_dicts


# Pfad mit Pfadparameter {x}
@app.get('/todos/{todo_id}/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_todo(todo_id: int, conn=Depends(get_connection)):
    select_query = 'select * from todos where id = ?;'

    cursor = conn.cursor()
    cursor.execute(select_query, (todo_id,))
    todos = cursor.fetchall()

    for todo in todos:
        todo_dict = {'id': todo[0], 'title': todo[1], 'status': todo[2], 'priority': todo[3]}
        if todo_dict['id'] == todo_id:
            return todo_dict


# Endpoint unfinished
@app.get('/todos/unfinished/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_unfinished_todos(conn=Depends(get_connection)):
    finished_query = '''SELECT * FROM todos 
                        WHERE status = 0;'''

    cursor = conn.cursor()
    cursor.execute(finished_query)
    todos = cursor.fetchall()
    todos_dict = []
    for todo in todos:
        todo_dict = {'id': todo[0], 'title': todo[1], 'status': todo[2], 'priority': todo[3]}
        todos_dict.append(todo_dict)
    return todos


# Endpoint finished
@app.get('/todos/finished/', status_code=status.HTTP_200_OK, tags=['get data'])
def get_finished_todos(conn=Depends(get_connection)):
    finished_query = '''SELECT * FROM todos 
                        WHERE status = 1;'''

    cursor = conn.cursor()
    cursor.execute(finished_query)
    todos = cursor.fetchall()
    todos_dict = []
    for todo in todos:
        todo_dict = {'id': todo[0], 'title': todo[1], 'status': todo[2], 'priority': todo[3]}
        todos_dict.append(todo_dict)
    return todos


### POST-Request

@app.post('/todos/', status_code=status.HTTP_201_CREATED, tags=['controller'])
def post_todo(todo: Todo, conn=Depends(get_connection)):
    insertion_query = '''INSERT INTO todos (title, status, priority)
                         VALUES (?, ?, ?);'''
    todo_tuple = (todo.title, todo.status, todo.priority)

    cursor = conn.cursor()
    cursor.execute(insertion_query, todo_tuple)
    conn.commit()
    cursor.close()
    conn.close()


### PATCH-Request

@app.patch('/todos/update', status_code=status.HTTP_204_NO_CONTENT, tags=['controller'])
def update_status(todo_id: int, conn=Depends(get_connection)):
    update_stmt = 'UPDATE todos SET status = 1 WHERE id = ?;'
    update_tuple = (todo_id,)
    cursor = conn.cursor()
    cursor.execute(update_stmt, update_tuple)
    conn.commit()
    cursor.close()
    conn.close()


@app.patch('/todos/update_rollback', status_code=status.HTTP_204_NO_CONTENT, tags=['controller'])
def update_status_rollback(todo_id: int, conn=Depends(get_connection)):
    update_status_rollback_stmt = 'UPDATE todos SET status = 0 WHERE id = ?;'
    update_tuple = (todo_id,)
    cursor = conn.cursor()
    cursor.execute(update_status_rollback_stmt, update_tuple)
    conn.commit()
    cursor.close()
    conn.close()


### DELETE REQUEST

@app.delete('/todos/delete/{todo_id}/', status_code=status.HTTP_204_NO_CONTENT, tags=['controller'])
def delete_todo(todo_id: int, conn=Depends(get_connection)):
    delete_stmt = 'DELETE FROM todos WHERE id = ?;'
    todo_tuple = (todo_id,)
    cursor = conn.cursor()
    cursor.execute(delete_stmt, todo_tuple)
    conn.commit()
    cursor.close()
    conn.close()


if __name__ == "__main__":
    uvicorn.run(app, host='127.0.0.1', port=8000)
