ANSIBLE=ansible-playbook site.yml -i hosts -K
DEPENDENCIES=site.yml
HOSTS=$(shell grep -v "^\[" hosts | grep -v "^$$" | sort | uniq)
ROLES=$(shell grep "^\[" hosts | sort | tr -d "\[" | tr -d "]")

define ITERATE
	$(shell echo "" >> $(2))
	$(shell echo "- hosts:$(1)" >> $(2))
	$(shell echo "  tags:$(1)" >> $(2))
	$(shell echo "  roles:" >> $(2))
	$(shell echo "    -$(1)" >> $(2))
endef

default: $(DEPENDENCIES)
	$(ANSIBLE)

$(HOSTS): $(DEPENDENCIES)
	$(ANSIBLE) --limit $@

$(ROLES): $(DEPENDENCIES)
	$(ANSIBLE) --tags $@

site.yml: hosts
	@echo Updating $@...
	$(shell echo "---" > $@)
	$(shell echo "" >> $@)
	$(shell echo "- hosts: all" >> $@)
	$(shell echo "  roles:" >> $@)
	$(shell echo "    - common" >> $@)
	$(foreach role, $(ROLES), $(call ITERATE, $(role), $@))

clean:
	$(RM) *.retry site.yml
