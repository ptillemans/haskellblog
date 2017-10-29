# Haskell version of SnamBlog

A small blog application aimed at technical blogging written in Haskell.

## Approach

### Start from yesod mongo scaffolding

I wanted to try using something else than a SQL database in the backend, so
I opted to play with mongo for this project.

### Stick to a classic webapp

Since the aim is to get experience with haskell we'll do as much as possible
server side instead of using a heavy frontend application ala react, vue or
angular.

Dealing with all parts of the app in Haskell will give a wider set of problems
to solve than just some API glue between the frontend and the persistent
storage.

I'll add an API later (if I am not bored by then)

### Test Driven approach

I want to test drive the functionality rather than the implementation.

There are 2 reasonings for this

- the strict type system restrictions do a lot of the triangularisation that would
  normally be done with small unit tests.
- I do not know enough of Yesod or Haskell to effectively test-drive the
  implementation
- it would slow down experimentation too much.

also, but I did not know that at the beginning, the fix-compile-test cycle takes
too long to be too detailed on implementation testing.

## Issues

### The mongo connection is initially slow.

The homepage loads on my laptop in about 7ms, except when it is loaded for the
first time or when there has been no database access for 20s, because then
almost exactly 2s is added to the response time.

This is related to the idle connection timeout in the mongodb connection pool,
which is default 20s.

A small python script

```python
from pymongo import MongoClient
from pprint import pprint

user = "snamblog"
pwd = "snamblog"
host = "localhost"
url = f"mongodb://{user}:{pwd}@{host}"
print(f"URL: {url}")
client = MongoClient(url)
db = client.snamblog
pprint(db.Blog.find_one())
client.close()

```

which connects to the database and runs some trivial query,
when timed and executed with

```sh
haskell/snamblog - [master●] » time python test_mongo.py
URL: mongodb://snamblog:snamblog@localhost
{'_id': ObjectId('59f4891c68834f8f1e000000'),
 'article': '# Mijn eerste post.\r\nDit is mijn eerste post',
 'posted': datetime.datetime(2017, 10, 28, 13, 41, 45, 909000),
 'title': 'Eerste Post'}
python test_mongo.py  0.18s user 0.05s system 31% cpu 0.733 total

```

runs in 0.18s, and that includes python startup and similar overhead.


## Lessons Learned

### When you think you understand something, you're (often) wrong

Haskell has a very frustrating learning curve and this project showed me several
more examples of this.

The concepts go very deep. Each time you understand an aspect of a concept it is
like removing a skirt of an onion while peeling onions. Each peel reveals a
deeper skirt to be peeled before reaching the core.

I am still far away from the core.

This is just the learning process of increasing understanding, but like chess,
Haskell is brutally honest when showing you the limits of your understanding.

### When it compiles it (mostly) runs

Once you get it to compile it will run and there will be very few surprises with
the code.

The only suprise I encountered so far was that the server started but threw
runtime exceptions because not all authorization combinations were covered.
There probably was a warning somewhere in the output of *yesod devel* but since
this mainly runs in the background I missed it.

### Compilation times

It can take quite some time to compile the files. This takes its toll
when practicing TDD.

Maybe I am doing it wrong. I have to play more with the repl to see if that can
help.

### Yesod devel and stack test conflict with each other

Another frustration while testing the code is that both *yesod devel* and *stack
test* will be compiling the code concurrently which causes errors like

```
[12 of 12] Compiling Application      ( src/Application.hs, .stack-work/dist/x86_64-osx/Cabal-1.24.2.0/build/Application.o )
ghc: panic! (the 'impossible' happened)
  (GHC version 8.0.2 for x86_64-apple-darwin):
    Loading temp shared object failed: dlopen(/var/folders/w3/blmqbpvx6510f7vx8yqvrj040000gn/T/ghc64281_0/libghc_62.dylib, 5): Symbol not found: _snamblogzm0zi0zi0zmBX5sr9gL5bMHYYAb7LInDi_SettingsziStaticFiles_csszubootstrapzucss1_closure
  Referenced from: /var/folders/w3/blmqbpvx6510f7vx8yqvrj040000gn/T/ghc64281_0/libghc_62.dylib
  Expected in: flat namespace
 in /var/folders/w3/blmqbpvx6510f7vx8yqvrj040000gn/T/ghc64281_0/libghc_62.dylib

```

to appear, which is extremely scary the first time.


### Actually very productive

On the whole, it is actually a very productive environment.
