import viz
import viztask
import steamvr
import datetime
import scipy.io as scio
import math
import utils


nSecWait			= 6 	# number of seconds of data to capture to determine noise in the tracker output
multiplier 			= 100	# set thresholds at mean+lambda*SD times the noise recorded, where lmbda is the multiplier set here
qHaveSimultaneous	= True 	# use setup with Vive and simultaneous PPT and Intersense (True), or not (False)?


setup = utils.init(qHaveSimultaneous)


viz.clearcolor(viz.WHITE)

def TrackTask():
	prevPos = None
	tracking= True
	allData = []
	tRegained = 0.
	waitingForTrack = True
	t = 0.
	while True:
		# wait for trigger press
		while not (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
			# limit to update rate
			d=yield viztask.waitDraw()
			
		# record n seconds of data
		tRegained = d.time
		while True:
			pos = setup.trackerDataFun()
			if prevPos is not None and pos['vive']==prevPos['vive']:
				# position didn't change at all, not tracking
				if tracking:
					print 'track lost'
					allData = []
					waitingForTrack = True
				tracking = False
			else:
				# get here only once vive position/orientation starts changing again
				if not tracking:
					print 'track regained'
					tRegained = t
				tracking = True
				if waitingForTrack and t-tRegained > nSecWait:
					# time to record some data
					waitingForTrack = False
					break
					
			pos['timeStamp'] = d.time
			prevPos = pos
			allData.append(pos)
			
			# limit to update rate
			d = yield viztask.waitDraw()
			t = d.time
				
		# calculate mean and SD for each variable of Vive
		means = [0.]*6
		SDs   = [0.]*6
		for dat in allData:
			for i,e in enumerate(dat['vive']):
				means[i] += e
		N = len(allData)
		means = [x/N for x in means]
		# now SD
		for dat in allData:
			for i,e in enumerate(dat['vive']):
				SDs[i] += (e-means[i])**2
		SDs = [math.sqrt(x)/(N-1) for x in SDs]
		
		# NB: for analysis of simulataneous data, can just do it qualitative. plot position/orientation over time for both vive and
		# other source. see offset in time between curves, that gives you differential latency.
		
		# wait for threshold exceeded, until controller trigger pulled that stops things
		setup.sounds.trialStart.play()
		exceeded = []
		d = yield viztask.waitDraw()
		visible = True
		while not (steamvr.getControllerList()[0].isButtonDown(2) or viz.key.isDown('c', immediate=True)):
			pos = setup.trackerDataFun()
			pos['timeStamp'] = d.time
			allData.append(pos)
			
			# check threshold
			qThresh = [abs(x-m)>s*multiplier for x,m,s in zip(pos['vive'],means,SDs)]
			if any(qThresh) and visible:
				for v in setup.visuals:
					v.visible(viz.OFF)
				visible = False
				exceeded.append(len(allData))	# store at which sample this happened
			
			# limit to screen update rate
			d = yield viztask.waitDraw()
		
		# save data and exit
		setup.sounds.trialCompleted.play()
		
		time = datetime.datetime.now()
		fname = ''.join((str(time.year) +
						str(time.month).zfill(2) +
						str(time.day).zfill(2) +
						str(time.hour).zfill(2) +
						str(time.minute).zfill(2) +
						str(time.second).zfill(2)))
				
		saveData = {}
		saveData['data'] = allData
		saveData['means'] = means
		saveData['SDs'] = SDs
		saveData['multiplier'] = multiplier
		saveData['exceeded'] = exceeded
		scio.savemat('data/'+fname,saveData,long_field_names=True,do_compression=True,oned_as='column')
				
		# done
		viz.quit()


viztask.schedule(TrackTask())