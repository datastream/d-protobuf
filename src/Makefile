# Define required macros here
SHELL = /bin/sh

OBJS = preprocessor.o
CC = ldc
SRCS = preprocessor.d AST.d analysis.d descriptor.d prototype.d writer.d codegen.d
MAIN = compiler.d analysis.o AST.o descriptor.o prototype.o writer.o codegen.o
TAG = compiler
LIB =

compiler:${OBJS}
	${CC} ${MAIN} -g ${OBJS} ${LIBS} $<
${OBJS}:depend
	${CC} ${SRCS} -c -g $<
all:${OBJS}
	${CC} ${MAIN} -g ${OBJS} ${LIBS}
depend: 
	makedepend -- ${SRCS}
clean:
	-rm -f *.o core *.core a.out ${TAG} Makefile.bak
# DO NOT DELETE
