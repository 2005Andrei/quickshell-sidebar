#include "cJSON.h"
#include <stdio.h>
#include <stdlib.h>
#include <uuid/uuid.h>

int main() {
  uuid_t binuuid;
  char uuid_str[37];
  uuid_generate_random(uuid_str);
  uuid_unparse_lower(binuuid, uuid_str);

  printf("Generated uuid: %s\n", uuid_str);

  cJSON *root = cJSON_CreateObject();
  cJSON_AddStringToObject(root, "works", "true");
  cJSON_AddStringToObject(root, "test_uuid", uuid_str);
  cJSON_AddNumberToObject(root, "tasks_processed", 0);

  char *json_string = cJSON_Print(root);
  printf("json: %s\n", json_string);

  free(json_string);
  cJSON_Delete(root);

  return 0;
}
