#include <cstdio>
#ifdef _DEBUG
#include <conio.h>
#endif

void usage(char *exe){
	printf("Usage: \n");
	printf("%s -i input_folder -o output_folder\n", exe);
#ifdef _DEBUG
	printf("Press any key to quit\n");
	getch();
#endif
}

int main(int argc, char **argv){
	usage(argv[0]);
}