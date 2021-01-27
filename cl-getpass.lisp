;;;; cl-getpass.lisp

(in-package #:cl-getpass)

(defvar *ccl-echo-mask* (logior #$ECHO #$ECHOE #$ECHOK #$ECHONL))

(defun echo-on (&optional (stream *standard-input*))
  "Attempts to enable input echoing for STREAM"
  #+(or abcl clasp clisp ufasoft-lisp cormanlisp gcl wcl lispworks mkcl poplog scl xcl) (error "Right now I only support a few impls :(")

  #+(or ccl mcl openmcl) (progn (require "PTY")
                                (ccl::enable-tty-local-modes (or (ccl::stream-device stream :input)
                                                                 (ccl::stream-device stream :output))
                                                             *ccl-echo-mask*))
  #+allegro (excl.osi:enable-terminal-echo stream)

  #+cmu (let ((file-stream (system:fd-stream-fd stream)))
          (alien:with-alien ((io (alien:struct unix:termios)))
            (unix:unix-tcgetattr file-stream io)
            (setf (alien:slot io 'unix:c-lflag) (logior (alien:slot io 'unix:c-lflag)
                                                        unix:tty-echo unix:tty-echoe
                                                        unix:tty-echok unix:tty-echonl))
            (unix:unix-tcsetattr file-stream unix:tcsanow io)))

  #+ecl (ffi:c-inline ((ext:file-stream-fd stream)) (:int) (values)
                      "{struct termios t; tcgetattr(#0, &t); t.c_lflag |= ECHO|ECHOE|ECHOK|ECHONL; tcsetattr(#0, TCSANOW, &t);}")

  #+sbcl (let* ((file-stream (sb-posix:file-descriptor stream))
                (io (sb-posix:tcgetattr file-stream)))
           (setf (sb-posix:termios-lflag io)
                 (logior (sb-posix:termios-lflag io)
                         sb-posix:echo sb-posix:echoe sb-posix:echok sb-posix:echonl))
           (sb-posix:tcsetattr file-stream sb-posix:tcsanow io))

  (values))

(defun echo-off (&optional (stream *standard-input*))
  "Attempts to disable input echoing for STREAM"

  #+(or ccl mcl openmcl) (progn (require "PTY")
                                (ccl::disable-tty-local-modes (or (ccl::stream-device stream :input)
                                                                  (ccl::stream-device stream :output))
                                                              *ccl-echo-mask*))
  #+allegro (excl.osi:disable-terminal-echo stream)

  #+cmu (let ((file-stream (system:fd-stream-fd stream)))
          (alien:with-alien ((io (alien:struct unix:termios)))
            (unix:unix-tcgetattr file-stream io)
            (setf (alien:slot io 'unix:c-lflag) (logandc2 (alien:slot io 'unix:c-lflag)
                                                          (logior unix:tty-echo unix:tty-echoe
                                                                  unix:tty-echok unix:tty-echonl)))
            (unix:unix-tcsetattr file-stream unix:tcsanow io)))

  #+ecl (ffi:c-inline ((ext:file-stream-fd stream)) (:int) (values)
                      "{struct termios t; tcgetattr(#0, &t); t.c_lflag &= ~(ECHO|ECHOE|ECHOK|ECHONL); tcsetattr(#0, TCSANOW, &t);}")

  #+sbcl (let* ((file-stream (sb-posix:file-descriptor stream))
                (io (sb-posix:tcgetattr file-stream)))
           (setf (sb-posix:termios-lflag io)
                 (logandc2 (sb-posix:termios-lflag io)
                           (logior sb-posix:echo sb-posix:echoe sb-posix:echok sb-posix:echonl)))
           (sb-posix:tcsetattr file-stream sb-posix:tcsanow io))

  (values))

(defun getpass (&optional (prompt "Enter password: ") (stream *standard-input*))
  #+swank(format *error-output* "WARNING: cl-readpass can't (yet) hide input from SLIME streams!!!~%")
  #+(or abcl clasp clisp ufasoft-lisp cormanlisp gcl wcl lispworks mkcl poplog scl xcl) (error "Right now I only support a few impls :(")
  (format stream "~a" prompt)
  (let (secret)
    (unwind-protect
         (prog2
             (echo-off stream)
             (setf secret (read-line stream)))
      (echo-on stream))
    secret))
