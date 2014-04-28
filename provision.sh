echo 'Building postgresql'

sudo apt-get update
sudo apt-get install git build-essential gettext
sudo apt-get install libreadline6 libreadline6-dev
sudo apt-get install zlib1g-dev
sudo apt-get install flex
git clone http://git.postgresql.org/git/postgresql.git



cd postgres
./configure
make
sudo make install

export PATH=$PATH:/usr/local/pgsql/bin

cd ..
mkdir data
export PGDATA=/home/vagrant/data

initdb

echo "host    all             all             0.0.0.0/0            trust" >> /home/vagrant/data/pg_hba.conf
pg_ctl -D /home/vagrant/data/ -l pg.log start


sudo apt-get install subversion
svn checkout http://v8.googlecode.com/svn/trunk/ v8
cd v8
make dependeincies
