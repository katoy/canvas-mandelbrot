"use strict"

compute = (y, xmin, dx, columns, maxIterations) ->
  iterationCounts = []

  for i in [0 .. columns]
    
    [x0, y0] = [xmin + i * dx, y]
    [a, b, ct] = [x0, y0, 0]

    while a * a + b * b < 4.1
      ct++
      (ct = -1; break) if (ct > maxIterations)
      [a, b] = [a * a - b * b + x0, 2 * a * b + y0]

    iterationCounts[i] = ct

  iterationCounts

@onmessage = (msg) ->
  job = msg.data
  counts = compute(job.y, job.xmin, job.dx, job.columns, job.maxIterations)
  postMessage
    workerNum: job.workerNum
    jobNum: job.jobNum
    row: job.row
    iterationCounts: counts

