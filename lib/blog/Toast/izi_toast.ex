defmodule Blog.Toast.IziToast do
  @moduledoc false
  import Phoenix.HTML.Tag
  import Phoenix.HTML
  import Plug.Conn

  @defaults [
    position: "bottomRight",
    theme: "light",
    timeout: 5000,
    close: true,
    titleSize: 18,
    messageSize: 18,
    progressBar: true
  ]

  def izi_toast(conn) do
    # toasts = get_session(conn, :izitoast)
    toasts = conn.assigns[:izitoast]

    if toasts do
      [toast_required_tags(), create_toast_tag(toasts)]
    end
  end

  def flash(conn, opts) do
    # toasts = get_session(conn, :izitoast)
    toasts = conn.assigns[:izitoast]

    if(toasts) do
      opts = toasts ++ [opts]
      assign(conn, :izitoast, opts)
    else
      assign(conn, :izitoast, [opts])
    end

    # assign(conn, :izitoast, opts)
    # put_session(conn, :message, "new stuff we just set in the session")
  end

  def make_toast(conn, title, message, color, opts) do
    opts = Keyword.merge(Application.get_env(:phx_izitoast, :opts) || [], opts)

    IO.inspect(opts)

    merged_opts = Keyword.merge(@defaults, opts)
    final_opts = merged_opts ++ [title: title, message: message, color: color]
    IO.inspect(final_opts)
    flash(conn, final_opts)
  end

  def make_toast(conn, title, message, color),
    do: make_toast(conn, title, message, color, [])

  def message(conn, message),
    do: make_toast(conn, " ", message, "blue", [])

  def success(conn, title, message, opts),
    do: make_toast(conn, title, message, "green", opts)

  def success(conn, title, message),
    do: make_toast(conn, title, message, "green", [])

  def info(conn, title, message, opts),
    do: make_toast(conn, title, message, "blue", opts)

  def info(conn, title, message),
    do: make_toast(conn, title, message, "blue", [])

  def warning(conn, title, message, opts),
    do: make_toast(conn, title, message, "yellow", opts)

  def warning(conn, title, message),
    do: make_toast(conn, title, message, "yellow", [])

  def error(conn, title, message, opts),
    do: make_toast(conn, title, message, "red", opts)

  def error(conn, title, message),
    do: make_toast(conn, title, message, "red", [])

  def create_toast_tag(toasts) do
    for toast <- toasts do
      content_tag(:script, raw("
        var options = {
          title: '#{toast[:title]}',
          message: '#{toast[:message]}',
          color: '#{toast[:color]}', // blue, red, green, yellow
          position: '#{toast[:position]}', // bottomRight, bottomLeft, topRight, topLeft, topCenter, bottomCenter, center
          theme: '#{toast[:theme]}', // dark
          timeout: #{toast[:timeout]},
          close: #{toast[:close]},
          titleSize: '#{toast[:titleSize]}',
          messageSize: '#{toast[:messageSize]}',
          progressBar: '#{toast[:progressBar]}'
      };
      var color = '#{toast[:color]}';
      if (color === 'blue'){
            iziToast.info(options);
        }
        else if (color === 'green'){
            iziToast.success(options);
        }
        else if  (color === 'yellow'){
            iziToast.warning(options);
        }
        else if (color === 'red'){
            iziToast.error(options);
        } else {
            iziToast.show(options);
        }
      // console.log('here')
      "), type: 'text/javascript')
    end
  end

  def toast_required_tags do
    ~E(<link href="/css/iziToast.css" rel="stylesheet" />
        <script src="/js/iziToast.js"></script>)
  end
end
