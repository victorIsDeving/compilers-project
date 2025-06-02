/* A Bison parser, made by GNU Bison 2.3.  */

/* Skeleton interface for Bison's Yacc-like parsers in C

   Copyright (C) 1984, 1989, 1990, 2000, 2001, 2002, 2003, 2004, 2005, 2006
   Free Software Foundation, Inc.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2, or (at your option)
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor,
   Boston, MA 02110-1301, USA.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Tokens.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
   /* Put the tokens into the symbol table, so that GDB and other debuggers
      know about them.  */
   enum yytokentype {
     ID = 258,
     NUM = 259,
     FNUM = 260,
     CNUM = 261,
     INT = 262,
     FLOAT = 263,
     CHAR = 264,
     IF = 265,
     ELSE = 266,
     WHILE = 267,
     READ = 268,
     WRITE = 269,
     MAIN = 270,
     PLUS = 271,
     MINUS = 272,
     MULT = 273,
     DIV = 274,
     ASSIGN = 275,
     EQ = 276,
     NE = 277,
     LT = 278,
     GT = 279,
     SEMICOLON = 280,
     LPAREN = 281,
     RPAREN = 282,
     LBRACE = 283,
     RBRACE = 284
   };
#endif
/* Tokens.  */
#define ID 258
#define NUM 259
#define FNUM 260
#define CNUM 261
#define INT 262
#define FLOAT 263
#define CHAR 264
#define IF 265
#define ELSE 266
#define WHILE 267
#define READ 268
#define WRITE 269
#define MAIN 270
#define PLUS 271
#define MINUS 272
#define MULT 273
#define DIV 274
#define ASSIGN 275
#define EQ 276
#define NE 277
#define LT 278
#define GT 279
#define SEMICOLON 280
#define LPAREN 281
#define RPAREN 282
#define LBRACE 283
#define RBRACE 284




#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE
#line 52 "parser.y"
{
    char* str;
    int num;
    float fnum;
}
/* Line 1529 of yacc.c.  */
#line 113 "parser.tab.h"
	YYSTYPE;
# define yystype YYSTYPE /* obsolescent; will be withdrawn */
# define YYSTYPE_IS_DECLARED 1
# define YYSTYPE_IS_TRIVIAL 1
#endif

extern YYSTYPE yylval;

