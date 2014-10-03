TOOLSDIR = /usr/lib/puavo-image-tools

PRECISE_IMAGE_TARGETS = thinclient-precise

TRUSTY_IMAGE_TARGETS = opinsys-trusty           \
		       opinsysextra-trusty      \
		       opinsysrestricted-trusty \
		       puavo-trusty

IMAGE_TARGETS = $(PRECISE_IMAGE_TARGETS) $(TRUSTY_IMAGE_TARGETS)

CHROOT_TARGETS = chroot                        \
                 cleanup-chroot                \
                 dist-upgrade                  \
                 image                         \
                 puppet-chroot                 \
                 puppet-chroot-error-on-change \
                 puppet-local                  \
                 update-chroot

OTHER_TARGETS = all help ${CHROOT_TARGETS}

BUILDS_DIR = $(shell awk '$$1 == "builds-dir" { print $$2 }' \
                       ~/.config/puavo-build-image/defaults)

help:
	@echo "Available targets are:"
	@echo "  ${OTHER_TARGETS}" | fmt
	@echo
	@echo "Available image types are:"
	@echo "  ${IMAGE_TARGETS}" | fmt

all: ${IMAGE_TARGETS}

${PRECISE_IMAGE_TARGETS}:
	@sudo puavo-build-image                            \
           --build $(@:%-precise=%) --distribution precise \
           --target-dir ${BUILDS_DIR}/$@

${TRUSTY_IMAGE_TARGETS}:
	@sudo puavo-build-image                          \
           --build $(@:%-trusty=%) --distribution trusty \
           --target-dir ${BUILDS_DIR}/$@

chroot cleanup-chroot dist-upgrade image puppet-chroot puppet-chroot-error-on-change puppet-local update-chroot:
	@TARGET_DIR=$$(${TOOLSDIR}/puavo-ask-buildtarget-dir ${BUILDS_DIR}) \
	  && sudo puavo-build-image --$@ --target-dir $${TARGET_DIR}

.PHONY: ${IMAGE_TARGETS} ${OTHER_TARGETS}
