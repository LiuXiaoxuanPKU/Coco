import heapq
import multiprocessing
import os
import subprocess
import signal
import threading
from pathlib import Path
from inject import inject

thread_pool = threading.Semaphore(multiprocessing.cpu_count())

def collect(dir: Path):
    result = []
    for batch in dir.glob("**/*.batch/"):
        tasks = list(batch.glob("*.json"))
        heapq.heappush(result, (sum(task.stat().st_size for task in tasks) / max(1, len(tasks)), tasks, batch.name))
    return result

def prove_batch(i: int, name: str, tasks: list[Path]):
    provable = "-1"
    for task in sorted(tasks, key=lambda path: int(path.stem)):
        try:
            subprocess.run(["cosette-prover", task], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            lines = task.with_suffix(".res").read_text().splitlines()
            if len(lines) > 0 and lines[0].strip().lower() == "true":
                provable = task.name
                break
        except:
            continue
    print(f'#{i}: {name} is {"not " if provable == "-1" else ""}provable')
    thread_pool.release()

def prove(sqls: Path, constraint: Path):
    subprocess.run(["cosette-parser", sqls])
    inject(constraint, sqls)
    os.setpgrp()
    try:
        plan = collect(sqls)
        i = 0
        while plan:
            thread_pool.acquire()
            i += 1
            _, tasks, batch = heapq.heappop(plan)
            threading.Thread(target=prove_batch, args=[i, batch, tasks]).start()
    except:
        os.killpg(0, signal.SIGKILL)