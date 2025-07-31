defmodule Malin.Uploaders.S3Uploader do
  @moduledoc """
  Helper module for S3 file operations
  """

  @doc """
  Uploads a file to S3 and returns the public URL
  """
  def upload_file(path, client_name) do
    # Generate a unique filename
    ext = Path.extname(client_name)
    filename = "#{UUID.uuid4()}_#{Path.basename(client_name, ext)}#{ext}"

    # Read file contents
    contents = File.read!(path)

    # Get bucket name
    bucket = System.get_env("AWS_S3_BUCKET")

    # Upload to S3
    {:ok, _response} =
      ExAws.S3.put_object(bucket, filename, contents, [
        {:content_type, MIME.from_path(client_name)}
      ])
      |> ExAws.request(
        access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
        secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY"),
        region: System.get_env("AWS_REGION")
      )

    # Construct and return the public URL
    cloudfront_domain = System.get_env("AWS_CLOUDFRONT_DOMAIN")
    "#{cloudfront_domain}/#{filename}"
  end

  @doc """
  Deletes a file from S3 if it exists and meets criteria
  """
  def delete_old_file(nil, _new_url), do: :ok

  def delete_old_file(old_url, new_url) do
    # Only delete if it's an S3 file and different from the new one
    if String.contains?(old_url, "s3.amazonaws.com") && old_url != new_url do
      bucket = System.get_env("AWS_S3_BUCKET")
      # Extract the filename from the old URL
      old_filename = List.last(String.split(old_url, "/"))

      # Delete the old file from S3
      ExAws.S3.delete_object(bucket, old_filename)
      |> ExAws.request()
    end

    :ok
  end
end
