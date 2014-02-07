require 'msf/core'

class Metasploit3 < Msf::Auxiliary

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Descarga de archivos automatica ',
      'Description'    => %q{
          Este modulo sirve para descargar archivos desde una web especificando la extesion de los archivos a descargar.
      },
      'License'        => MSF_LICENSE,
      'Author'         =>
        [
          'luisco <luisco[at]gmail.com>' # Metasploit module
        ]
    ))

    register_options(
      [
		OptString.new('WEBSITE', [ true, "Webpage to extract its words", "http://ejemplo.com" ]),
		OptString.new('FILETYPE', [ true, "Tipo de archivo (incluir punto)", ".pdf" ]),
        OptString.new('FILEPATH', [true, 'The path of the file to download', '/tmp/'])
      ], self.class)

#     deregister_options('RHOST')
  end

  def run()
	website = datastore['WEBSITE'] + datastore['FILEPATH']
	print_status(website)
	page = Net::HTTP.get_response(URI.parse(website)).body
	find_urls_on_page(website,page)
  end
  
  def find_urls_on_page(url,content)
	tipo_archivo = datastore['FILETYPE']
	list_urls = content.scan(/<a.+?href="(.+?)".+? /)
    print_status("Imprimir enlaces ...")
	print_status("tamaño: #{list_urls.size}")
	list_urls.each do |my_url|
		print_status(my_url[0])
		if my_url[0].include? tipo_archivo
			file_download = my_url[0]
			print_status("Enlace : #{my_url}")
			download_file("#{url}#{file_download}")
		end	
     end
  end
  
  def my_basename(filename)
    return ::File.basename(filename.gsub(/\\/, "/"))
  end
  
  def download_file(url)
	
	buffer_size = 4096
	filename = url.split('/')[-1]
	print_status("Descargando desde: #{url} ")
	# open(filename, 'wb') do |file|
	  # file << open(url).read
	# end

	
	open(url, "r",
       :content_length_proc => lambda {|content_length| puts "Content
length: #{content_length} bytes" },
       :progress_proc => lambda { |size| printf("Read %010d bytes\r",
size.to_i) }) do |input|
				open(filename, "wb") do |output|
					while (buffer = input.read(buffer_size))
						output.write(buffer)
					end
					end
				end
	
	
	
  end
    
end
