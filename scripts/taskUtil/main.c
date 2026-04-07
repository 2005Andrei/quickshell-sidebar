#include "cJSON.h"
#include <errno.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <uuid/uuid.h>

#define LIST_NAMES "/home/andrei/.local/share/tasks/list_names.txt"
#define LISTS_FILE "/home/andrei/.local/share/tasks/lists.json"
#define TASKS_FILE "/home/andrei/.local/share/tasks/tasks.json"
#define DATA_FILE "/home/andrei/.local/share/errands/data.json"

/*
 * the plan was to be able to modify errands (an app to track tasks) from my
 * sidebar I didn't know it has persistent memory - I found that out the hard
 * way after I'd already managed to load and delete tasks from the app.
 *
 * just to not have spent this time figuring out the cJSON library for nothing,
 * I'll change the role of this code to be a system utility that writes and
 * updates tasks as needed
 *
 * some of these functions are left overs from me trying to reduce the JSON
 * objects from the errands data file, that I might integrate at some point
 * because I still think I'm going to want to view errands tasks from my sidebar
 * */

void get_formatted_time(char *buffer, size_t size) {
    time_t t = time(NULL);
    struct tm *tm_info = localtime(&t);

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

    printf("%s\n", uuid_str);

    cJSON_AddStringToObject(task, "created_at", time_str);
    cJSON_AddStringToObject(task, "list_uid", list_uid);
    cJSON_AddStringToObject(task, "text", text);
    cJSON_AddStringToObject(task, "uid", uuid_str);

    cJSON_AddBoolToObject(task, "completed", 0);
    cJSON_AddBoolToObject(task, "deleted", 0);

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

        cJSON *new_task = create_new_task(task_text, list_uid);

        cJSON *content = read_json_from_file(TASKS_FILE);

        cJSON_AddItemToArray(content, new_task);

        char *string_content = cJSON_Print(content);
        int size = strlen(string_content);

        FILE *data_file = fopen(TASKS_FILE, "w");

        if (data_file == NULL) {
            printf("Great failure"); // shouldn't happen though
            return 1;
        }

        fwrite(string_content, 1, size, data_file);

        fclose(data_file);

        free(string_content);
        cJSON_Delete(content); // this deletes all the children, including tasks
                               // and new_task

        return 0;
    }

    if (argc == 3 && strcmp(argv[1], "--delete") == 0) {
        cJSON *tasks = read_json_from_file(TASKS_FILE);

        cJSON *task = NULL;

        cJSON_ArrayForEach(task, tasks) {
            cJSON *uid = cJSON_GetObjectItem(task, "uid");

            if (strcmp(argv[2], cJSON_GetStringValue(uid)) == 0) {
                break;
            }
        }

        if (task == NULL) {
            printf("\ntask not found");
            cJSON_Delete(tasks);
            return 1;
        }

        cJSON *deleted = cJSON_GetObjectItem(task, "deleted");
        cJSON_DeleteItemFromObject(task, "deleted");
        cJSON_AddBoolToObject(task, "deleted", !cJSON_IsTrue(deleted));

        char *curr_task = cJSON_Print(task);
        printf("\n%s\n", curr_task);

        FILE *data_f = fopen(TASKS_FILE, "w");

        char *jtasks = cJSON_Print(tasks);
        int size = strlen(jtasks);

        fwrite(jtasks, 1, size, data_f);

        fclose(data_f);

        free(jtasks);
        cJSON_Delete(tasks);

        return 0;
    }

    if (argc == 3 && strcmp(argv[1], "--complete") == 0) {
        cJSON *tasks = read_json_from_file(TASKS_FILE);

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

        cJSON *completed = cJSON_GetObjectItem(task, "completed");
        cJSON_DeleteItemFromObject(task, "completed");
        cJSON_AddBoolToObject(task, "completed", !cJSON_IsTrue(completed));

        char *curr_task = cJSON_Print(task);
        printf("\n%s\n", curr_task);

        FILE *data_f = fopen(TASKS_FILE, "w");

        char *jtasks = cJSON_Print(tasks);
        int size = strlen(jtasks);

        fwrite(jtasks, 1, size, data_f);

        fclose(data_f);

        free(jtasks);
        cJSON_Delete(tasks);

        return 0;
    }

    // at the moment, I can only define lists from a file
    if (argc == 2 && strcmp(argv[1], "sync-lists") == 0) {
        FILE *lists = fopen(LIST_NAMES, "r");

        if (lists == NULL) {
            perror("fopen");
            return 1;
        }

        char buffer[32];
        char *list_names[50];
        int i = 0;

        while (fscanf(lists, "%s", buffer) == 1) {
            list_names[i] = strdup(buffer);
            i++;
        }

        fclose(lists);

        cJSON *curr_lists = read_json_from_file(LISTS_FILE);
        cJSON *jbuffer = NULL;

        for (int j = 0; j < i; j++) {
            int included = 0;
            cJSON_ArrayForEach(jbuffer, curr_lists) {
                cJSON *cur_name = cJSON_GetObjectItem(jbuffer, "name");
                char *name = cJSON_GetStringValue(cur_name);

                if (strcmp(list_names[j], name) == 0) {
                    printf("included\n");
                    included = 1;
                }
            }

            if (!included) {
                printf("not included again\n");
                char uid[37];
                get_uuid(uid);

                cJSON *new_list_object = cJSON_CreateObject();
                cJSON_AddStringToObject(new_list_object, "name", list_names[j]);
                cJSON_AddStringToObject(new_list_object, "uid", uid);

                char *list_content = cJSON_Print(new_list_object);
                printf("%s\n", list_content);

                cJSON_AddItemToArray(curr_lists, new_list_object);
            }
        }

        FILE *write_list_stream = fopen(LISTS_FILE, "w");

        char *content = cJSON_Print(curr_lists);
        int size = strlen(content);

        fwrite(content, 1, size, write_list_stream);

        fclose(write_list_stream);

        return 0;
    }

    // a leftover to sync tasks and lists with the errands app
    if (argc == 2 && strcmp(argv[1], "sync") == 0) {
        cJSON *content = read_json_from_file(DATA_FILE);

        cJSON *tasks = cJSON_GetObjectItem(content, "tasks");
        cJSON *lists = cJSON_GetObjectItem(content, "lists");

        write_list_file(lists);
        write_tasks_file(tasks);

        cJSON_Delete(content);

        return 0;
    }

    return 0;
}
