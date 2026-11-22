define require_path
$(if $(realpath $1),$(realpath $1),$(error Path not found $1))
endef
