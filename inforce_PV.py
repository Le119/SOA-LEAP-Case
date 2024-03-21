import csv
import mortality_rate as mr

def add_APV(inforce, APV):

    print(inforce[0])

    for row in inforce:
        if str(row[3]) in APV:
            row.append(str(float(APV[row[3]]) * float(row[5])))
        else:
            row.append("NA")
    return inforce

if __name__ == '__main__':

    with open('SPWL_Actuarial_PV.csv', mode='r') as csv_file:
        SPWL_APV = csv.reader(csv_file)
        data = [row for row in SPWL_APV]
        data = data[1:]
        SPWL_APV = {}
        for row in data:
            SPWL_APV[row[0]] = row[1]

    with open('T20_Actuarial_PV.csv', mode='r') as csv_file:
        T20_APV = csv.reader(csv_file)
        data = [row for row in T20_APV]
        data = data[1:]
        T20_APV = {}
        for row in data:
            T20_APV[row[0]] = row[1]
        

    with open('2024-srcsc-superlife-inforce-dataset.csv', mode='r') as csv_file:
        inforce = csv.reader(csv_file)
        data = [row for row in inforce]
        col_names = data[3]
        data = data[4:]
        data = mr.add_death_age(data)
        data = mr.add_lapse_age(data)
        T20, SPWL = mr.divide_T20_SPWL(data)
        #T20 = add_APV(T20, T20_APV)
        SPWL = add_APV(SPWL, SPWL_APV)
    
    with open('SPWL_inforce_PV.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(col_names + ["Death.age", "Lapse.age", "PV"])

        for row in SPWL:
            writer.writerow(row)

