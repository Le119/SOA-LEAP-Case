import csv

def kPx(interest_table, x, k, starting_age):
    s = 0
    for i in range(x - starting_age, x + k - starting_age):
        # Ensure i is within the bounds of interest_table
        if 0 <= i < len(interest_table):
            # Check if the value at index 4 is numeric
            if interest_table[i][4].replace('.', '', 1).isdigit():
                s += float(interest_table[i][4])
            else:
                print(f"Non-numeric value encountered at age {i + starting_age} in kPx")
        else:
            print(f"Age {i + starting_age} out of range in kPx")
    return s

def Qxk(interest_table, x, k, starting_age):
    index = x - starting_age + k
    # Check if index is within bounds
    if 0 <= index < len(interest_table):
        return float(interest_table[index][2])
    else:
        print(f"Age {index + starting_age} out of range in Qxk")
        return 0  # Return a default value or handle error

def Vk1(interest_table, k):
    p = 1
    for i in range(0, k):
        # Ensure i is within the bounds of interest_table
        if 0 <= i < len(interest_table):
            p *= float(interest_table[i][7])
        else:
            print(f"Issue year {i + 2001} out of range in Vk1")
            break  # Exit the loop or handle error
    return p

def termed_actuarial_present_value(interest_table, x, n, starting_age):
    val = 0
    for k in range(n):
        # Calculate the index for the current age + k
        index = x + k - starting_age
        # Check if index is within the bounds of interest_table
        if 0 <= index < len(interest_table):
            val += (Vk1(interest_table, k) * kPx(interest_table, x, k, starting_age) * Qxk(interest_table, x, k, starting_age))
        else:
            print(f"Age {x + k} out of range in termed_actuarial_present_value")
    return val

if __name__ == '__main__':
    with open('T20-mortality.csv', mode='r', newline='') as csv_file:
        n = 20  # T20
        lst = []
        interest_table_i = csv.reader(csv_file)
        interest_table = [row for row in interest_table_i]
        interest_table = interest_table[2:]

        for row in interest_table:
            age = int(row[0])
            apv = termed_actuarial_present_value(interest_table, age, n, 26)
            lst.append([age, apv])  # Append as a list

    with open('T20_Actuarial_PV.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["Age", "APVx"])

        for row in lst:
            writer.writerow([str(row[0]), str(row[1])])  # Convert each element to string

    # Repeat the process for SPWL-mortality.csv
    with open('SPWL-mortality.csv', mode='r', newline='') as csv_file:
        lst = []
        interest_table_i = csv.reader(csv_file)
        interest_table = [row for row in interest_table_i]
        interest_table = interest_table[2:]
        n = 23
        for row in interest_table:
            age = int(row[0])
            apv = termed_actuarial_present_value(interest_table, age, n, 35)
            lst.append([age, apv])  # Append as a list

    with open('SPWL_Actuarial_PV.csv', mode='w', newline='') as csv_file:
        writer = csv.writer(csv_file)
        writer.writerow(["Age", "APVx"])

        for row in lst:
            writer.writerow([str(row[0]), str(row[1])])  # Convert each element to string
