config() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  # If there's no config file by that name, mv it over:
  if [ ! -r $OLD ]; then
    mv $NEW $OLD
  elif [ "$(cat $OLD | md5sum)" = "$(cat $NEW | md5sum)" ]; then
    # toss the redundant copy
    rm $NEW
  fi
  # Otherwise, we leave the .new copy for the admin to consider...
}

preserve_perms() {
  NEW="$1"
  OLD="$(dirname $NEW)/$(basename $NEW .new)"
  if [ -e $OLD ]; then
    cp -a $OLD ${NEW}.incoming
    cat $NEW > ${NEW}.incoming
    mv ${NEW}.incoming $NEW
  fi
  config $NEW
}

config etc/lighttpd2/lighttpd.conf.new
config etc/lighttpd2/angel.conf.new
config etc/lighttpd2/mimetypes.conf.new
config etc/logrotate.d/lighttpd2.new
preserve_perms etc/rc.d/rc.lighttpd2.new
preserve_perms etc/rc.d/rc.spawn-fcgi.new

# Create dummy logfiles, but throw them away if logfiles are already here:
for i in access error ; do 
  if [ -e var/log/lighttpd2/${i}.log ]; then
    rm -f var/log/lighttpd2/${i}.log.new
  else 
    mv var/log/lighttpd2/${i}.log.new var/log/lighttpd2/${i}.log
  fi
done

