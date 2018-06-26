#!/usr/bin/env python2.7
import dbus
import dbus.exceptions
import dbus.mainloop.glib
import dbus.service
from threading import Thread

import array
try:
  from gi.repository import GObject
except ImportError:
  import gobject as GObject
import sys
from random import randint

from imutils.video import VideoStream
from imutils import face_utils
from gpiozero import TrafficHat
import RPi.GPIO
import numpy as np
import imutils
import time
import dlib
import cv2
import os
from threading import Thread

mainloop = None
sig= 80


BLUEZ_SERVICE_NAME = 'org.bluez'
GATT_MANAGER_IFACE = 'org.bluez.GattManager1'
DBUS_OM_IFACE =      'org.freedesktop.DBus.ObjectManager'
DBUS_PROP_IFACE =    'org.freedesktop.DBus.Properties'

GATT_SERVICE_IFACE = 'org.bluez.GattService1'
GATT_CHRC_IFACE =    'org.bluez.GattCharacteristic1'
GATT_DESC_IFACE =    'org.bluez.GattDescriptor1'

class InvalidArgsException(dbus.exceptions.DBusException):
    _dbus_error_name = 'org.freedesktop.DBus.Error.InvalidArgs'

class NotSupportedException(dbus.exceptions.DBusException):
    _dbus_error_name = 'org.bluez.Error.NotSupported'

class NotPermittedException(dbus.exceptions.DBusException):
    _dbus_error_name = 'org.bluez.Error.NotPermitted'

class InvalidValueLengthException(dbus.exceptions.DBusException):
    _dbus_error_name = 'org.bluez.Error.InvalidValueLength'

class FailedException(dbus.exceptions.DBusException):
    _dbus_error_name = 'org.bluez.Error.Failed'


class Application(dbus.service.Object):
    """
    org.bluez.GattApplication1 interface implementation
    """
    def __init__(self, bus):
        self.path = '/'
        self.services = []
        dbus.service.Object.__init__(self, bus, self.path)
        self.add_service(NotificationService(bus, 0))
       
    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_service(self, service):
        self.services.append(service)

    @dbus.service.method(DBUS_OM_IFACE, out_signature='a{oa{sa{sv}}}')
    def GetManagedObjects(self):
        response = {}
        print('GetManagedObjects')

        for service in self.services:
            response[service.get_path()] = service.get_properties()
            chrcs = service.get_characteristics()
            for chrc in chrcs:
                response[chrc.get_path()] = chrc.get_properties()
                descs = chrc.get_descriptors()
                for desc in descs:
                    response[desc.get_path()] = desc.get_properties()

        return response


class Service(dbus.service.Object):
    """
    org.bluez.GattService1 interface implementation
    """
    PATH_BASE = '/org/bluez/example/service'

    def __init__(self, bus, index, uuid, primary):
        self.path = self.PATH_BASE + str(index)
        self.bus = bus
        self.uuid = uuid
        self.primary = primary
        self.characteristics = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        return {
                GATT_SERVICE_IFACE: {
                        'UUID': self.uuid,
                        'Primary': self.primary,
                        'Characteristics': dbus.Array(
                                self.get_characteristic_paths(),
                                signature='o')
                }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_characteristic(self, characteristic):
        self.characteristics.append(characteristic)

    def get_characteristic_paths(self):
        result = []
        for chrc in self.characteristics:
            result.append(chrc.get_path())
        return result

    def get_characteristics(self):
        return self.characteristics

    @dbus.service.method(DBUS_PROP_IFACE,
                         in_signature='s',
                         out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != GATT_SERVICE_IFACE:
            raise InvalidArgsException()

        return self.get_properties()[GATT_SERVICE_IFACE]


class Characteristic(dbus.service.Object):
    """
    org.bluez.GattCharacteristic1 interface implementation
    """
    def __init__(self, bus, index, uuid, flags, service):
        self.path = service.path + '/char' + str(index)
        self.bus = bus
        self.uuid = uuid
        self.service = service
        self.flags = flags
        self.descriptors = []
        dbus.service.Object.__init__(self, bus, self.path)

    def get_properties(self):
        return {
                GATT_CHRC_IFACE: {
                        'Service': self.service.get_path(),
                        'UUID': self.uuid,
                        'Flags': self.flags,
                        'Descriptors': dbus.Array(
                                self.get_descriptor_paths(),
                                signature='o')
                }
        }

    def get_path(self):
        return dbus.ObjectPath(self.path)

    def add_descriptor(self, descriptor):
        self.descriptors.append(descriptor)

    def get_descriptor_paths(self):
        result = []
        for desc in self.descriptors:
            result.append(desc.get_path())
        return result

    def get_descriptors(self):
        return self.descriptors

    @dbus.service.method(DBUS_PROP_IFACE,
                         in_signature='s',
                         out_signature='a{sv}')
    def GetAll(self, interface):
        if interface != GATT_CHRC_IFACE:
            raise InvalidArgsException()

        return self.get_properties()[GATT_CHRC_IFACE]

    @dbus.service.method(GATT_CHRC_IFACE,
                        in_signature='a{sv}',
                        out_signature='ay')
    def ReadValue(self, options):
        print('Default ReadValue called, returning error')
        raise NotSupportedException()

    @dbus.service.method(GATT_CHRC_IFACE, in_signature='aya{sv}')
    def WriteValue(self, value, options):
        print('Default WriteValue called, returning error')
        raise NotSupportedException()

    @dbus.service.method(GATT_CHRC_IFACE)
    def StartNotify(self):
        print('Default StartNotify called, returning error')
        raise NotSupportedException()

    @dbus.service.method(GATT_CHRC_IFACE)
    def StopNotify(self):
        print('Default StopNotify called, returning error')
        raise NotSupportedException()

    @dbus.service.signal(DBUS_PROP_IFACE,
                         signature='sa{sv}as')
    def PropertiesChanged(self, interface, changed, invalidated):
        pass

 

class NotificationService(Service):
    """
    This service send signal to peripheral.

    """
    BATTERY_UUID = '1811'

    def __init__(self, bus, index):
        Service.__init__(self, bus, index, self.BATTERY_UUID, True)
        self.add_characteristic(WaitSignalCharacteristic(bus, 0, self))


class WaitSignalCharacteristic(Characteristic):
    """
    for every 10ms, update the signal

    """
    BATTERY_LVL_UUID = '2a46'

    def __init__(self, bus, index, service):
        Characteristic.__init__(
                self, bus, index,
                self.BATTERY_LVL_UUID,
                ['read', 'notify'],
                service)
        self.notifying = False
        self.signal = sig
        
        #self.report_signal
        GObject.timeout_add(2000, self.report_signal)

    def notify_new_signal(self):
        if not self.notifying:
            return
        self.PropertiesChanged(
                GATT_CHRC_IFACE,
                { 'Value': [dbus.Byte(self.signal)] }, [])

    def report_signal(self):
        if not self.notifying:
            return True
        
        self.signal = sig
        
        print('New signal is: ' + repr(self.signal))
        self.notify_new_signal()
        return True

    def ReadValue(self, options):
        print('The new signal read: ' + repr(self.signal))
        return [dbus.Byte(self.signal)]

    def StartNotify(self):
        if self.notifying:
            print('Already notifying, nothing to do')
            return

        self.notifying = True
        self.notify_new_signal()

    def StopNotify(self):
        if not self.notifying:
            print('Not notifying, nothing to do')
            return

        self.notifying = False



def register_app_cb():
    print('GATT application registered')


def register_app_error_cb(error):
    print('Failed to register application: ' + str(error))
    mainloop.quit()


def find_adapter(bus):
    remote_om = dbus.Interface(bus.get_object(BLUEZ_SERVICE_NAME, '/'),
                               DBUS_OM_IFACE)
    objects = remote_om.GetManagedObjects()

    for o, props in objects.items():
        if GATT_MANAGER_IFACE in props.keys():
            return o

    return None

#---------------------
th = TrafficHat()
count = 0
yawns = 0
test_yawn = 0

while(count < 3):
    th.lights.red.on()
    time.sleep(0.3)
    th.lights.red.off()
    th.lights.amber.on()
    time.sleep(0.3)
    th.lights.amber.off()
    th.lights.green.on()
    time.sleep(0.3)
    th.lights.green.off()
    count += 1

def euclidean_dist(ptA, ptB):
	# compute and return the euclidean distance between the two
	# points
	return np.linalg.norm(ptA - ptB)

def eye_aspect_ratio(eye):
	# compute the euclidean distances between the two sets of
	# vertical eye landmarks (x, y)-coordinates
	A = euclidean_dist(eye[1], eye[5])
	B = euclidean_dist(eye[2], eye[4])

	# compute the euclidean distance between the horizontal
	# eye landmark (x, y)-coordinates
	C = euclidean_dist(eye[0], eye[3])

	# compute the eye aspect ratio
	ear = (A + B) / (2.0 * C)

	# return the eye aspect ratio
	return ear
    
def mouth_aspect_ratio(mouth):
    
    A = euclidean_dist(mouth[2], mouth[10])
    B = euclidean_dist(mouth[4], mouth[8])
    
    C = euclidean_dist(mouth[0], mouth[6])
    
    mar = (A + B)/ (2.0 * C)
    
    return mar
    


# define two constants, one for the eye aspect ratio to indicate
# blink and then a second constant for the number of consecutive
# frames the eye must be below the threshold for to set off the
# alarm
EYE_AR_THRESH = 0.245
EYE_AR_CONSEC_FRAMES = 2

MOUTH_AR_THRESH = 0.62
MOUTH_AR_CONSEC_FRAMES = 3

# initialize the frame counter as well as a boolean used to
# indicate if the alarm is going off
counter_eye = 0
counter_mouth = 0

detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')
predictor = dlib.shape_predictor('shape_predictor_68_face_landmarks.dat')


# grab the indexes of the facial landmarks for the left and
# right eye, respectively
(lStart, lEnd) = face_utils.FACIAL_LANDMARKS_IDXS["left_eye"]
(rStart, rEnd) = face_utils.FACIAL_LANDMARKS_IDXS["right_eye"]
(mStart, mEnd) = face_utils.FACIAL_LANDMARKS_IDXS["mouth"]


vs = VideoStream(usePiCamera=True).start()
time.sleep(1.0)

th.lights.green.on()

def yawn_once():
    th.lights.amber.blink(0.3,0.3,10,True)
        

def yawn_more_than_once():
    th.lights.red.blink(0.3,0.3,10,True)


def big_thread():
    service_manager.RegisterApplication(app.get_path(), {},
                                    reply_handler=register_app_cb,
                                    error_handler=register_app_error_cb)
 
    

def big_thread2():
    global yawns, count, test_yawn, sig, counter_eye, counter_mouth
    while True:
        while(th.button.is_pressed == True):
            th.lights.red.on()
            time.sleep(1)
            th.lights.red.off()
            #os.system("sudo hciconfig hci0 leadv 0")
            os.system("sudo reboot")
        
        frame = vs.read()
        frame = imutils.resize(frame, width=450)
        #frame = cv2.transpose(frame)
        #frame = cv2.flip(frame,0)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        
        #detect faces in the grayscale frame
        rects = detector.detectMultiScale(gray, scaleFactor=1.1, 
                    minNeighbors=5, minSize=(30, 30),
                    flags=cv2.CASCADE_SCALE_IMAGE)
        
        
        
        # loop over the face detections
        for (x, y, w, h) in rects:
                # construct a dlib rectangle object from the Haar cascade
                # bounding box
                rect = dlib.rectangle(int(x), int(y), int(x + w),
                        int(y + h))

                # determine the facial landmarks for the face region, then
                # convert the facial landmark (x, y)-coordinates to a NumPy
                # array
                shape = predictor(gray, rect)
                shape = face_utils.shape_to_np(shape)
                
                # extract the left and right eye coordinates, then use the
                # coordinates to compute the eye aspect ratio for both eyes
                leftEye = shape[lStart:lEnd]
                rightEye = shape[rStart:rEnd]
                mouth = shape[mStart:mEnd]
                leftEAR = eye_aspect_ratio(leftEye)
                rightEAR = eye_aspect_ratio(rightEye)
                mar = mouth_aspect_ratio(mouth)
        
                # average the eye aspect ratio together for both eyes
                ear = (leftEAR + rightEAR) / 2.0
                
                # check to see if the eye aspect ratio is below the blink
                # threshold, and if so, increment the blink frame counter
                if ear < EYE_AR_THRESH:
                        counter_eye += 1
                        # if the eyes were closed for a sufficient number of
                        # frames, then sound the alarm
                        if counter_eye >= EYE_AR_CONSEC_FRAMES:
                            th.buzzer.on()
                            sig = 82
                            
      
                # otherwise, the eye aspect ratio is not below the blink
                # threshold, so reset the counter and alarm
                else:
                    counter_eye = 0
                    th.buzzer.off()
                    sig = 80
                    
                if mar > MOUTH_AR_THRESH:
                    counter_mouth += 1
                    if counter_mouth > MOUTH_AR_CONSEC_FRAMES:
                        if test_yawn == 0:
                            yawns += 1
                            test_yawn = 1
                        
                        if yawns == 1:    
                            t1 = Thread(target = yawn_once)
                            t1.deamon = True
                            t1.start()
                        else:
                            t2 = Thread(target = yawn_more_than_once)
                            t2.deamon = True
                            t2.start()

                else:
                    counter_mouth = 0
                    test_yawn = 0

def main():
    global mainloop
    global service_manager, app
    dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)

    bus = dbus.SystemBus()

    adapter = find_adapter(bus)
    if not adapter:
        print('GattManager1 interface not found')
        return

    service_manager = dbus.Interface(
            bus.get_object(BLUEZ_SERVICE_NAME, adapter),
            GATT_MANAGER_IFACE)

    app = Application(bus)

    mainloop = GObject.MainLoop()

    print('Registering GATT application...')
    t1 = Thread(target = big_thread)
    t1.deamon = True
    t1.start()

    t2 = Thread(target = big_thread2)
    t2.deamon = True
    t2.start()
    
    mainloop.run()

if __name__ == '__main__':
    main()
