CFLAGS = -Wall -Wextra -O2 -g # -fsanitize=address
LDFLAGS = -luuid 


sync-tasks: main.o cJSON.o
	gcc main.o cJSON.o -o $@ $(LDFLAGS)

%.o: %.c
	gcc $(CFLAGS) -c $< -o $@

clean:
	rm -f sync-tasks main.o cJSON.o
