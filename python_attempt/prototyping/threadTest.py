#!/usr/bin/python
from multiprocessing.pool import ThreadPool
def sqr(num):
  val = num * num
  return val

def run():
  pool = ThreadPool(processes=10)
  
  a = 2  
  async_result = pool.apply_async(sqr, (a, )) # tuple of args for foo
  print async_result.get(timeout=1)           # prints "100" unless your computer is *very* slow
  l = [1, 2, 3, 4, 5]
  print pool.map(sqr, l)          # prints "[0, 1, 4,..., 81]"
  # do some other stuff in the main process

run()
