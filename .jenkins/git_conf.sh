if [ ! -f /var/lib/jenkins/.gitconfig ]; then
    git config --global url."git@bitbucket.org:".insteadOf https://bitbucket.org/
    git config --global url."git@gitlab.esss.lu.se:".insteadOf https://gitlab.esss.lu.se/
fi
