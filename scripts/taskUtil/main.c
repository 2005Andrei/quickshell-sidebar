#include "cJSON.h"
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <uuid/uuid.h>

#define LISTS_FILE "/home/andrei/.local/share/tasks/lists.json"
#define DATA_FILE "/home/andrei/.local/share/errands/data.json"
#define TASKS_FILE "/home/andrei/.local/share/tasks/tasks.json"

/*
 * small script that syncs tasks I define with the Errands app
 * (https://github.com/mrvladus/Errands). Errands stores tasks at
 * ~/.local/share/errands/data.json, and because I do not want qml handling too
 * much json, I decided to introduce a middleman this code will save tasks at
 * ~/.local/share/quickshell/tasks
 * this leaves me to add the following attributes:
 *      attachments: [],
 *      "color"
 *      "completed"
 *      "changed_at":"20260326T202631",
 *      "created_at":"20260326T202631",
 *      "deleted"
 *      "due_date"
 *      "expanded"
 *      "list_uid"
 *      "notes"
 *      "notified"
 *      "parent"
 *      "percent_complete"
 *      "priority"
 *      "rrule"
 *      "start_date"
 *      "synced"
 *      "tags":[
 *
 *       ],
 *      "text"
 *      "toolbar_shown"
 *      "trash"
 *      "uid"
 *
 *  tasks:
 *      1) load tasks from data.json
 *      2) ensure writing ability from qml, add it to data.json at the same time
 *      3) file watcher -> whenever a task is created from errands it gets added
 *         so qml can see it.
 *
 * */

// generate errands compliant time
void get_formatted_time(char *buffer, size_t size) {
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);

    printf("%ld", t);
    printf("\n%s", asctime(tm_info));

    strftime(buffer, size, "%Y%m%dT%H%M%S", tm_info);
}

// generate uuid
void get_uuid(char *buffer) {
    uuid_t binuuid;
    uuid_generate(binuuid);
    uuid_unparse(binuuid, buffer);
}

// creating a new task
cJSON *create_new_task(char *text, char *list_uid) {
    cJSON *task = cJSON_CreateObject();

    char time_str[16];
    char uuid_str[37];

    get_formatted_time(time_str, 16);
    get_uuid(uuid_str);

    cJSON_AddItemToObject(task, "attachments", cJSON_CreateArray());
    cJSON_AddItemToObject(task, "tags", cJSON_CreateArray());

    cJSON_AddStringToObject(task, "color", "");
    cJSON_AddStringToObject(task, "changed_at", time_str);
    cJSON_AddStringToObject(task, "created_at", time_str);
    cJSON_AddStringToObject(task, "due_date", "");
    cJSON_AddStringToObject(task, "list_uid", list_uid);
    cJSON_AddStringToObject(task, "notes", "");
    cJSON_AddStringToObject(task, "parent", "");
    cJSON_AddStringToObject(task, "rrule", "");
    cJSON_AddStringToObject(task, "start_date", "");
    cJSON_AddStringToObject(task, "text", text);
    cJSON_AddStringToObject(task, "uid", uuid_str);

    cJSON_AddBoolToObject(task, "completed", 0);
    cJSON_AddBoolToObject(task, "deleted", 0);
    cJSON_AddBoolToObject(task, "expanded", 0);
    cJSON_AddBoolToObject(task, "notified", 0);
    cJSON_AddNumberToObject(task, "percent_complete", 0);
    cJSON_AddNumberToObject(task, "priority", 0);
    cJSON_AddBoolToObject(task, "synced", 0);
    cJSON_AddBoolToObject(task, "toolbar_shown", 1);
    cJSON_AddBoolToObject(task, "trash", 0);

    return task;
}

// file utility, as the name suggests
cJSON *read_json_from_file(char *filename) {
    FILE *file = fopen(filename, "r");

    if (file == NULL) {
        perror("fopen");
        return NULL;
    }

    fseek(file, 0, SEEK_END);
    long length = ftell(file);

    fseek(file, 0, SEEK_SET);

    char *buffer = malloc(length + 1); // +1 because of the null terminator

    size_t end = fread(buffer, 1, length, file);
    buffer[end] = '\0';

    cJSON *jsonObj = cJSON_Parse(buffer);

    if (jsonObj == NULL) {
        printf("read_json_from_file: json obj is null");
    }

    return jsonObj;
}

cJSON *reduce_list_item(cJSON *item) {
    cJSON *deleted = cJSON_GetObjectItem(item, "deleted");
    cJSON_bool td = cJSON_IsTrue(deleted);

    if (td) {
        return NULL;
    }

    cJSON *reduced_list_item = cJSON_CreateObject();

    cJSON *text = cJSON_GetObjectItem(item, "name");
    cJSON *list_uid = cJSON_GetObjectItem(item, "uid");

    char *jtext = cJSON_GetStringValue(text);
    char *jlist_uid = cJSON_GetStringValue(list_uid);

    cJSON_AddStringToObject(reduced_list_item, "name", jtext);
    cJSON_AddStringToObject(reduced_list_item, "uid", jlist_uid);

    return reduced_list_item;
}

void write_list_file(cJSON *object) {
    cJSON *small_lists = cJSON_CreateArray();
    cJSON *buffer = NULL;
    cJSON_ArrayForEach(buffer, object) {
        cJSON *reduced_list_item = reduce_list_item(buffer);
        if (reduced_list_item != NULL) {
            cJSON_AddItemToArray(small_lists, reduced_list_item);
        }
    }

    char *jsmall_lists = cJSON_Print(small_lists);
    int size = strlen(jsmall_lists);

    FILE *lists_f = fopen(LISTS_FILE, "w");

    fwrite(jsmall_lists, 1, size, lists_f);

    fclose(lists_f);

    // free(jsmall_lists);
    // cJSON_Delete(small_lists);
    // cJSON_Delete(buffer);
}

cJSON *reduce_task_item(cJSON *item) {
    cJSON *reduced_task_item = cJSON_CreateObject();

    cJSON *text = cJSON_GetObjectItem(item, "text");
    cJSON *list_uid = cJSON_GetObjectItem(item, "list_uid");
    cJSON *deleted = cJSON_GetObjectItem(item, "deleted");
    cJSON *completed = cJSON_GetObjectItem(item, "completed");
    cJSON *uid = cJSON_GetObjectItem(item, "uid");

    char *jtext = cJSON_GetStringValue(text);
    char *jlist_uid = cJSON_GetStringValue(list_uid);
    char *juid = cJSON_GetStringValue(uid);

    cJSON_bool jd = cJSON_IsTrue(deleted);
    cJSON_bool jc = cJSON_IsTrue(completed);

    cJSON_AddStringToObject(reduced_task_item, "text", jtext);
    cJSON_AddStringToObject(reduced_task_item, "list_uid", jlist_uid);
    cJSON_AddStringToObject(reduced_task_item, "uid", juid);
    cJSON_AddBoolToObject(reduced_task_item, "completed", jc);
    cJSON_AddBoolToObject(reduced_task_item, "deleted", jd);

    return reduced_task_item;
}

void write_tasks_file(cJSON *object) {
    cJSON *small_tasks = cJSON_CreateArray();
    cJSON *buffer = NULL;

    cJSON_ArrayForEach(buffer, object) {
        cJSON *reduced_task_item = reduce_task_item(buffer);
        cJSON_AddItemToArray(small_tasks, reduced_task_item);
    }

    char *jsmall_tasks = cJSON_Print(small_tasks);
    int size = strlen(jsmall_tasks);

    FILE *sm_tasks_file = fopen(TASKS_FILE, "w");

    fwrite(jsmall_tasks, 1, size, sm_tasks_file);

    fclose(sm_tasks_file);
    cJSON_Delete(small_tasks);
}

int get_json_length(cJSON *json_array) {
    int count = 0;

    cJSON *curr = json_array->child;

    while (curr != NULL) {
        count++;
        curr = curr->child;
    }

    free(curr);
    return count;
}

// add task, sync, get lists
int main(int argc, char *argv[]) {

    if (argc == 1) {
        printf("Incorrect usage.");
        return 1;
    }

    if (argc == 5 && strcmp(argv[1], "--add") == 0 &&
        strcmp(argv[3], "--list") == 0) {
        char *task_text = argv[2];
        char *list_uid = argv[4];

        // create json obj to save in data.json
        cJSON *new_task = create_new_task(task_text, list_uid);

        if (new_task == NULL) {
            printf("great failure");
        }

        cJSON *content = read_json_from_file(DATA_FILE);

        cJSON *tasks = cJSON_GetObjectItem(content, "tasks");
        cJSON_AddItemToArray(tasks, new_task);

        char *string_content = cJSON_Print(content);
        int size = strlen(string_content);

        FILE *data_file = fopen("/home/andrei/Desktop/test.json", "w");

        if (data_file == NULL) {
            printf("Great failure");
        }

        fwrite(string_content, 1, size, data_file);

        fclose(data_file);

        cJSON_Delete(content); // this deletes all the children, including tasks
                               // and new_task

        return 0;
    }

    if (argc == 2 && strcmp(argv[1], "sync") == 0) {
        // when data.json gets updated
        cJSON *content = read_json_from_file(DATA_FILE);

        cJSON *tasks = cJSON_GetObjectItem(content, "tasks");
        cJSON *lists = cJSON_GetObjectItem(content, "lists");

        write_list_file(lists);
        write_tasks_file(tasks);

        cJSON_Delete(content);
    }

    if (argc == 3 && strcmp(argv[1], "--delete") == 0) {
        cJSON *content = read_json_from_file(DATA_FILE);

        cJSON *tasks = cJSON_GetObjectItem(content, "tasks");
        cJSON *task = NULL;

        cJSON_ArrayForEach(task, tasks) {
            cJSON *uid = cJSON_GetObjectItem(task, "uid");

            if (strcmp(argv[2], cJSON_GetStringValue(uid)) == 0) {
                break;
            }
        }

        if (task == NULL) {
            printf("\ntask not found");
            return 1;
        }

        cJSON *deleted = cJSON_GetObjectItem(task, "deleted");
        cJSON_DeleteItemFromObject(task, "deleted");
        cJSON_AddBoolToObject(task, "deleted", !cJSON_IsTrue(deleted));

        char *curr_task = cJSON_Print(task);
        printf("\n%s\n", curr_task);

        FILE *data_f = fopen(DATA_FILE, "w");

        char *jcontent = cJSON_Print(content);
        int size = strlen(jcontent);

        fwrite(jcontent, 1, size, data_f);

        fclose(data_f);

        free(jcontent);
    }

    if (argc == 3 && strcmp(argv[1], "--complete") == 0) {
    }

    return 0;
}
