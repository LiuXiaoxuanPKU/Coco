import json


def read_data(filename):    
    with open(filename, "r") as f:
        lines = f.readlines()
    data = {}
    for line in lines:
        obj = json.loads(line)
        obj['sp'] = obj["t_db"] / max(obj["t_rewrite_constraint"], 1e-5)
        data[obj['raw']] = obj
    return data

def compare(data1, data2):
    cnt = 0
    for k in data1:
        sp1 = data1[k]['sp']
        sp2 = data2[k]['sp']
        if sp2 > 1.05 and sp1 < 0.95:
            print(k, sp1, sp2)
            print(data1[k]['t_db'], data1[k]['t_rewrite_constraint'],  data2[k]['t_db'], data2[k]['t_rewrite_constraint'])
            print(data1[k]['rewrite'])
            print("")
            cnt += 1
    print(cnt)

if __name__ == "__main__":
    data1 = read_data("openproject_perf")
    data2 = read_data("openproject_perf_with_jit")
    compare(data1, data2)
    