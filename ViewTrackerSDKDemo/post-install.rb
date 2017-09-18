#
#在Podfifle中添加以下代码，实现post_install hook。
# begin
#    cocoapods_post_install if require './cocoapods-post-install.rb'
# rescue LoadError
# end


# 该脚本只是为了兼容0.39，增加了HEADER_SEARCH_PATHS。

def cocoapods_post_install
    # cocoapods 0.39.0将public header中的下一层级目录去掉了，所以对于framework中头文件的引用需要改为import <Framework/Header.h>的方式引入，这样是更规范，但是修改成本太高，且在framework与源码切换调试后，头文件有可能再报找不到。所以此处增加该脚本，将header search path改为和0.38一样，增加了下一层目录，这样业务方就不需要修改。对脚本有任何问题请@晨燕
    
    if Pod::VERSION >= '0.39.0'
        ENV["COCOAPODS_DISABLE_STATS"] = "1"
        Pod::Config.instance.deterministic_uuids = false 
        post_install do |installer|
            installer.pods_project.targets.each do |target|
                # 设置Pods-Target的xcconfig
                if target.name.include?"Pods-"
                    target.build_configurations.each do |config|
                        xcconfig_path = config.base_configuration_reference.real_path
                        build_settings = Hash[*File.read(xcconfig_path).lines.map{|x| x.split(/\s*=\s*/, 2)}.flatten]

                        header_search_path_array = build_settings['HEADER_SEARCH_PATHS'].split(" ")
                        append_search_path_array = Array.new
                        header_search_path_array.each do |path|
                            append_search_path_array << path
                            if path.include? "${PODS_ROOT}/Headers/Public/"
                                # 获取真实路径
                                realpath = path.gsub('${PODS_ROOT}',installer.sandbox.root.to_s).tr('\"\'','')
                                if Dir.exist?(realpath)
                                    # 对路径中的下一层级进行遍历
                                    Dir.entries(realpath).each do |entry|
                                        # 如果是文件夹
                                        if File.directory?(realpath+'/'+entry) and !(entry =='.' || entry == '..')
                                            # 组成一个新的路径
                                            new_path = '\''+path.tr('\"\'','')+'/'+entry+'\' '
                                            # 将新路径加入到数组中
                                            append_search_path_array << new_path
                                        end
                                    end
                                end
                            end
                        end
                        build_settings['HEADER_SEARCH_PATHS'] = append_search_path_array.join(" ")
                        
                        # write build_settings dictionary to xcconfig
                        File.open(xcconfig_path, "w")
                        build_settings.each do |key,value|
                            File.open(xcconfig_path, "a") {|file| file.puts "#{key} = #{value}"}
                        end
                    end
                end
            end
        end
    end
end

