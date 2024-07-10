FROM kasmweb/core-ubuntu-jammy:1.15.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

# fix missing  keys
COPY ./src/f6ecb3762474eda9d21b7022871920d1991bc93c.asc $INST_SCRIPTS/
COPY ./src/eb8b81e14da65431d7504ea8f63f0f2b90935439.asc $INST_SCRIPTS/
RUN cat $INST_SCRIPTS/f6ecb3762474eda9d21b7022871920d1991bc93c.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/F63F0F2B90935439.gpg >/dev/null 2>&1
RUN cat $INST_SCRIPTS/eb8b81e14da65431d7504ea8f63f0f2b90935439.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/871920D1991BC93C.gpg >/dev/null 2>&1
RUN chmod 755 /etc/apt/trusted.gpg.d
RUN chmod 644 /etc/apt/trusted.gpg.d/*

# Install Chromium
COPY ./src/ubuntu/install/chromium $INST_SCRIPTS/chromium/
RUN bash $INST_SCRIPTS/chromium/install_chromium.sh && rm -rf $INST_SCRIPTS/chromium/
# install stirling pdf
COPY ./src/ubuntu/install/s-pdf $INST_SCRIPTS/s-pdf/
RUN bash $INST_SCRIPTS/s-pdf/install_s-pdf.sh && rm -rf $INST_SCRIPTS/s-pdf/

# Update the desktop environment to be optimized for a single application
RUN cp $HOME/.config/xfce4/xfconf/single-application-xfce-perchannel-xml/* $HOME/.config/xfce4/xfconf/xfce-perchannel-xml/
RUN cp /usr/share/backgrounds/bg_kasm.png /usr/share/backgrounds/bg_default.png
RUN apt-get remove -y xfce4-panel

# Security modifications
COPY ./src/ubuntu/install/misc/single_app_security.sh $INST_SCRIPTS/misc/
RUN  bash $INST_SCRIPTS/misc/single_app_security.sh -t && rm -rf $INST_SCRIPTS/misc/
COPY ./src/common/chrome-managed-policies/urlblocklist.json /etc/chromium/policies/managed/urlblocklist.json

# Setup the custom startup script that will be invoked when the container starts
#ENV LAUNCH_URL  http://kasmweb.com

COPY ./src/ubuntu/install/chromium/custom_startup.sh $STARTUPDIR/custom_startup.sh
RUN chmod +x $STARTUPDIR/custom_startup.sh

# Install Custom Certificate Authority
# COPY ./src/ubuntu/install/certificates $INST_SCRIPTS/certificates/
# RUN bash $INST_SCRIPTS/certificates/install_ca_cert.sh && rm -rf $INST_SCRIPTS/certificates/

ENV KASM_RESTRICTED_FILE_CHOOSER=1
COPY ./src/ubuntu/install/gtk/ $INST_SCRIPTS/gtk/
RUN bash $INST_SCRIPTS/gtk/install_restricted_file_chooser.sh


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000
