import csv

def issue_age(u, data):
    # returns rows containing issue_age == u
    aged_policy = []
    for row in data:
        if int(row[3]) == u:
            aged_policy += row
    return aged_policy

def death_age(u, data):
    # returns rows containing death_age == u
    dead_policy = []
    for row in data:
        if (row[16].isnumeric()) and int(row[16]) == u:
            dead_policy += row
    return dead_policy

def lapse_age(u, data):
    # returns rows containing lapse_age == u
    end_policy = []
    for row in data:
        if (row[17].isnumeric()) and int(row[17]) == u:
            end_policy += row
    return end_policy

def motality_rate(ui, di, li, c):
    # returns (Ai, c) for the next iteration
    return (di / (ui + c - li), ui - di + c - li)

def find_min_issue_age(data):
    # returns min issue age
    min = 100
    for row in data:
        if int(row[3]) < min:
            min = int(row[3])
    return min

def find_max_death_age(data):
    # returns max death age
    max = 0
    for row in data:
        if (row[16].isnumeric()) and int(row[16]) > max:
            max = int(row[16])
    return max

def add_death_age(data):
    # adding a column for death_age at the end
    for row in data:
        if row[12].isnumeric():
            death_age = str(int(row[12]) - int(row[2]) + int(row[3]))
            row.append(death_age)
        else:
            row.append("NA")
    return data

def add_lapse_age(data):
    # adding a column for lapse_age at the end
    for row in data:
        if row[14].isnumeric():
            lapse_age = str(int(row[14]) - int(row[2]) + int(row[3]))
            row.append(lapse_age)
        else:
            row.append("NA")
    return data

if __name__ == '__main__':

    with open('2024-srcsc-superlife-inforce-dataset.csv', mode='r') as csv_file:
        inforce = csv.reader(csv_file)
        data = [row for row in inforce]
        col_names = data[3]
        data = data[4:]
        data = add_death_age(data)
        data = add_lapse_age(data)
        
        c = 0
        print("min age " + str(find_min_issue_age(data)))
        print("max age " + str(find_max_death_age(data)))
        mortality_table = []
        for u in range(find_min_issue_age(data), find_max_death_age(data) + 1):
            dead_u = death_age(u, data)
            issue_u = issue_age(u, data)
            lapse_u = lapse_age(u, data)
            (mu, c) = motality_rate(len(issue_u), len(dead_u), len(lapse_u), c)

            print(len(dead_u))
            print(c)
            mortality_table.append([u, mu])
        print(mortality_table)

    with open('inforce_motality_rate.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["Age", "Mortality Rate"])

        for row in mortality_table:
            writer.writerow(row)
        

        