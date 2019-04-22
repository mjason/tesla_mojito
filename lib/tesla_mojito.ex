
defmodule Tesla.Adapter.Mojito do

  @behaviour Tesla.Adapter
  alias Tesla.Multipart

  def child_spec(opts \\ []) do
    Mojito.Pool.child_spec(:mojito_tesla_pool, opts)
  end

  def call(env, opts) do
    with {:ok, status, headers, body} <- request(env, opts) do
      {:ok, %{env | status: status, headers: format_headers(headers), body: format_body(body)}}
    end
  end

  defp format_headers(headers) do
    for {key, value} <- headers do
      {String.downcase(to_string(key)), to_string(value)}
    end
  end

  defp format_body(data) when is_list(data), do: IO.iodata_to_binary(data)
  defp format_body(data) when is_binary(data), do: data

  defp request(env, opts) do
    request(
      env.method,
      Tesla.build_url(env.url, env.query),
      env.headers,
      env.body,
      Tesla.Adapter.opts(env, opts)
    )
  end

  defp request(method, url, headers, %Multipart{} = mp, opts) do
    headers = headers ++ Multipart.headers(mp)
    body = Multipart.body(mp)

    request(method, url, headers, body, opts)
  end

  defp request(method, url, headers, body,
    [pool: true] = opts) do
    try do
      handle(Mojito.Pool.request(:mojito_tesla_pool, method, url, headers, body || '', opts))
    catch
      :exit, message -> handle({:error, message})
    end
  end

  defp request(method, url, headers, body, opts) do
    try do
      handle(Mojito.request(method, url, headers, body || '', opts))
    catch
      :exit, message -> handle({:error, message})
    end
  end

  defp handle({:error, _} = error) do
   error
  end

  defp handle({:ok, %Mojito.Response{body: body, headers: headers, status_code: status}}) do
    {:ok, status, headers, body}
  end
end