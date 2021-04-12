# import csv
# import pandas as pd
# from io import StringIO

import matplotlib.pyplot as plt
import numpy as np


def string_to_list(string):
     return [float(i) for i in string.split()]

baudRate = 14400
nT = 24
T = 16e-3

datos = "137 136 135 132 131 129 127 125 123 122 120 118 116 118 120 122 124 125 127 129 131 132 134 136 138 136 134 132 130 128 126 125 123 121 119 118 116 118 120 122 124 126 128 129 131 133 135 136 138 135 134 132 130 128 126 124 122 121 119 117 117 119 121 123 125 126 128 130 132 133 135 137 137 135 133 131 129 127 125 124 122 120 119 117 117 "


V = np.array(string_to_list(datos))*5/255
t1_ = np.linspace(0, T/2, 50)
t2_ = np.linspace(T/2, T, 50)
V_teo = []

t = np.array([i for i in range(len(V))])*16e-3/nT
print("Valor máximo y mínimo de V sobre el capacitor: {:.2f} V  y {:.2f} V".format(max(V)*5/255, min(V)*5/255))
C = 2.7
V_down = C*np.e**(-t1_/0.05)
V_up = 5 - V_down
V_teo = np.concatenate((V_down, V_up, V_down, V_up, V_down, V_up, V_down))
t_teo = np.linspace(0, 7/2*T, 50*7)


plt.figure(figsize=(10, 5))

plt.plot(t_teo*1000, V_teo, color="tab:blue", label="Ideal")
plt.plot(t*1000, V, '.', color="tab:red", label="Muestras")

plt.legend()
plt.minorticks_on()
plt.gca().set_axisbelow(True)
plt.grid(which="major", alpha=0.9)
plt.grid(which="minor", alpha=0.4)
plt.ylim(2.25, 2.75)
plt.xlim(0, t[-1]*1000)
plt.xlabel('$t$ [ms]', fontsize=14)
plt.ylabel('$V$ [V]', fontsize=14)

plt.savefig("muestras.pdf", dpi=500, bbox_inches="tight")

plt.show()