import collections
import struct
import time
from threading import Thread
import time

import matplotlib; matplotlib.use("TkAgg")
import matplotlib.animation as animation
import matplotlib.pyplot as plt
import numpy as np
import serial


# baudRate = 38400
baudRate = 14400


class serialPlot:
    def __init__(self, serialPort = 'COM3', serialBaud = baudRate, plotLength = 100, dataNumBytes = 1):
        self.port = serialPort
        self.baud = serialBaud
        self.plotMaxLength = plotLength
        self.dataNumBytes = dataNumBytes
        self.rawData = bytearray(dataNumBytes)
        self.data = collections.deque([0] * plotLength, maxlen=plotLength)
        self.isRun = True
        self.isReceiving = False
        self.write_timeout = 1
        self.thread = None
        self.plotTimer = 0
        self.previousTimer = 0
        # self.csvData = []

        print('Trying to connect to: ' + str(serialPort) + ' at ' + str(serialBaud) + ' BAUD.')
        try:
            self.serialConnection = serial.Serial(serialPort, serialBaud, timeout=4)
            print('Connected to ' + str(serialPort) + ' at ' + str(serialBaud) + ' BAUD.')
        except:
            print("Failed to connect with " + str(serialPort) + ' at ' + str(serialBaud) + ' BAUD.')

    def readSerialStart(self):
        if self.thread == None:
            self.thread = Thread(target=self.backgroundThread)
            self.thread.start()
            # Block till we start receiving values
            while self.isReceiving != True:
                time.sleep(0.1)

    def getSerialData(self, frame, lines, lineValueText, lineLabelValue, prom):
        value,  = struct.unpack('B', self.rawData)    # use 'h' for a 2 byte integer
        self.data.append(value*5/255)    # we get the latest data point and append it to our array
        prom = sum(self.data) / len(self.data)
        lineValueText.set_text(lineLabelValue + ' = ' + "{:.2f}".format(prom) + ' V')
        lines.set_data([i*10/baudRate*1000 for i in range(self.plotMaxLength)], self.data)


    def backgroundThread(self):    # retrieve data
        time.sleep(1.0)  # give some buffer time for retrieving data
        self.serialConnection.reset_input_buffer()
        while (self.isRun):
            self.serialConnection.readinto(self.rawData)
            self.isReceiving = True
            #print(self.rawData)

    def close(self):
        self.isRun = False
        self.thread.join()
        self.serialConnection.close()
        print('Disconnected...')
        # df = pd.DataFrame(self.csvData)
        # df.to_csv('/home/rikisenia/Desktop/data.csv')


def main(baudRate):
    prom=0
    portName = 'COM3'
    maxPlotLength = 100
    dataNumBytes = 1        # number of bytes of 1 data point
    s = serialPlot(portName, baudRate, maxPlotLength, dataNumBytes)   # initializes all required variables
    s.readSerialStart()                                               # starts background thread

    # plotting starts below
    pltInterval = 1    # Period at which the plot animation updates [ms]
    xmin = 0
    xmax = maxPlotLength
    ymin = 0
    ymax = 5
    fig = plt.figure()
    ax = plt.axes(xlim=(xmin, xmax), ylim=(float(ymin - (ymax - ymin) / 10), float(ymax + (ymax - ymin) / 10)))
    ax.set_title('Lectura del Osciloscopio')
    ax.set_xlabel("Tiempo [ms]")
    ax.set_ylabel("Salida del RC [V]")

    lineLabelValue = 'Valor Medio'
    lineLabel = 'Tensión C'
    lineValueText = ax.text(0.7, 0.95, '', transform=ax.transAxes)
    lines = ax.plot([], [], label=lineLabel)[0]
    anim = animation.FuncAnimation(fig, s.getSerialData, fargs=(lines, lineValueText, lineLabelValue, prom), interval=pltInterval)    # fargs has to be a tuple

    plt.legend(loc="upper left")
    plt.show()

    s.close()


if __name__ == '__main__':
    main(baudRate)