YUV		= ffmpeg
YUVFLAGS	= -f rawvideo -pix_fmt yuv420p -y
CLEAN		= rm -rf

DIRS		= graph log motion out recon
DIRS		:= $(patsubst %,%.fast,${DIRS}) \
                   $(patsubst %,%.fastconstrained,${DIRS})
DIRS		+= in

ENCODER		= H264AVCEncoderLibTestStatic
UNCONCFG	= encoder.cfg
UNCONLOG	= log
CONCFG		= encoder.constrained.cfg
CONLOG		= log.constrained
FASTCFG		= encoder.fast.cfg
FASTLOG		= log.fast
FASTCONCFG	= encoder.fastconstrained.cfg
FASTCONLOG	= log.fastconstrained
TIME		= command time

IMGDIR		= ../frames
RANGE		= %03d
NVIEWS		= 2
VIEWORDER	= 0 1 

all: dirs yuvs fastconstrained fast graphs

fast:
	@for view in ${VIEWORDER}; do \
        	echo -e "\n########\n######## `date`" \
        		| tee -a ${FASTLOG}/log_$${view}.txt \
        		| tee -a ${FASTLOG}/err_$${view}.txt \
        		>> ${FASTLOG}/time_$${view}.txt; \
		${TIME} -ao ${FASTLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FASTCFG} $${view} \
			>> ${FASTLOG}/log_$${view}.txt \
			2>> ${FASTLOG}/err_$${view}.txt; \
        done
fastconstrained:
	@for view in ${VIEWORDER}; do \
        	echo -e "\n########\n######## `date`" \
        		| tee -a ${FASTCONLOG}/log_$${view}.txt \
        		| tee -a ${FASTCONLOG}/err_$${view}.txt \
        		>> ${FASTCONLOG}/time_$${view}.txt; \
		${TIME} -ao ${FASTCONLOG}/time_$${view}.txt ${ENCODER} -vf v$${view}_${FASTCONCFG} $${view} \
			>> ${FASTCONLOG}/log_$${view}.txt \
			2>> ${FASTCONLOG}/err_$${view}.txt; \
        done

dirs:
	@-for dir in ${DIRS}; do \
		mkdir $$dir 2>/dev/null; \
	done

graphs:
	@for mot in motion*/*.mot; do \
		if [ "plot*.sh" ]; then \
			for plot in plot*.sh; do \
				echo "Running $$plot in $$mot"; \
				./$$plot $$mot; \
			done; \
		fi; \
	done
	@for log in log*/log*.txt; do \
		if [ "chart*.sh" ]; then \
			for chart in chart*.sh; do \
				echo "Running $$chart in $$mot"; \
				./$$chart $$log; \
			done; \
		fi; \
	done

yuvs:
	@for i in ${VIEWORDER}; do \
		${YUV} -i ${IMGDIR}/$$((i+1)).${RANGE}.png ${YUVFLAGS} in/in_$${i}.yuv; \
	done

clean: clean-graphs
clean-all: clean clean-output clean-input
mrproper: clean-all clean-logs

clean-graphs:
	${CLEAN} graph*
clean-output:
	${CLEAN} out* recon* motion*
clean-input:
	${CLEAN} in
clean-logs:
	${CLEAN} log*

.PHONY: all unconstrained constrained graphs yuvs clean clean-all mrproper clean-graphs clean-input clean-output clean-logs
