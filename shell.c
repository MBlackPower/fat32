/* Generic C Headers */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "futil.h"

typedef struct arg_info_s {
    int argc;
    char **argv;
} arg_info_t;

static char *current_dir = "/";

arg_info_t tokenize(char *input) {
    int num_cmds = 2;
    for (int i = 0; i < strlen(input); i++) {
        if (input[i] == ' ') ++num_cmds;
    }
    
    arg_info_t arg_info;
    char *token;
    arg_info.argv = calloc(num_cmds+1, sizeof(char*));
    for (arg_info.argc = 0; (token = strtok(NULL, " ")) != NULL; arg_info.argc++) {
        arg_info.argv[arg_info.argc] = token;
    }
    
    arg_info.argv[num_cmds] = (char*)'\0';
    return arg_info;
}

char * prepend_path(char *path) {
    if (path == NULL) { return NULL; }
    
    if (path[0] != '/') {
        char *full_path = calloc(strlen(path) + strlen(current_dir) + 1, sizeof(char));
        strcpy(full_path, current_dir);
        strcat(full_path, path);
        return full_path;
    }
    
    return path;
}

void mount(arg_info_t args) {
    if (args.argc == 0) {
        for (int i = 0; i < MOUNT_LIMIT; i++) {
            if (mount_table[i] != NULL) {
                printf("%s on %s type %s\n", mount_table[i]->device_name, mount_table[i]->path, "FAT32");
            }
        }
        return;
    } else if (args.argc < 2) {
        printf("usage: mount device mount-point\n");
        return;
    }
    
    char *device_name = args.argv[args.argc - 2];
    char *path = args.argv[args.argc - 1];
    
    mount_fs(device_name, path);
}

void umount(arg_info_t args) {
    if (args.argc != 1) {
        printf("usage: umount mount-point\n");
        return;
    }
    unmount_fs(args.argv[0]);
}

void ls(arg_info_t args) {
    if (args.argc != 0) {
        printf("usage: ls\n");
        return;
    }
    int dir = opendir("/"); 
    char *file;
    //readdir(dir);
    while ((file = readdir(dir)) != NULL) {
        printf("%s\n", file);
    }
}

void touch(arg_info_t args) {
    if (args.argc != 1) {
        printf("usage: touch filename\n");
        return;
    }
    
    int fp = fileopen(prepend_path(args.argv[0]));
    filewrite(fp, "", 1);
    fileclose(fp);
}

int main(int argc, char **argv) {

    char *input;
    
    /* Temporarily auto mount hello */
    //mount_fs("hello", "/");
    mount_fs("/dev/sde1", "/");
    
    while (1) {
        printf("> ");
        input = calloc(80, sizeof(char));
        input = fgets(input, 80, stdin);
        input[strlen(input)-1] = '\0';  // Strip New Line
        
        char *cmd = strtok(input, " ");
        if (cmd != NULL) {
            if (strcmp(cmd, "exit") == 0) {
                free(input);
                break;
            } else if(strcmp(cmd, "mount") == 0) {
                mount(tokenize(input));
            } else if(strcmp(cmd, "umount") == 0) {
                umount(tokenize(input));
            } else if (strcmp(cmd, "ls") == 0) {
                ls(tokenize(input));
            } else if (strcmp(cmd, "touch") == 0) {
                touch(tokenize(input));
            }
        }
        
        free(input);
    }
    
    return EXIT_SUCCESS;
}