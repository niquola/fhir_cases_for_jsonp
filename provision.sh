# echo 'Building postgresql'
sudo apt-get update
sudo apt-get install -y git build-essential gettext
sudo apt-get install -y libreadline6 libreadline6-dev
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y flex bison

# run as vagrant user
git clone http://git.postgresql.org/git/postgresql.git ~/postgresql

sudo chown vagrant:vagrant -R ~/postgresql

# run as vagrant

exit 1
cd ~/postgres
./configure
make
sudo make install

cp -R ~/jsonb/jsquery ~/postgresql/contrib
cd ~/postgresql/contrib/jsquery
make
sudo make install

export PATH=$PATH:/usr/local/pgsql/bin

echo 'export PATH=$PATH:/usr/local/pgsql/bin' >> ~/.bashrc

cd ~/
mkdir data
export PGDATA=/home/vagrant/data

initdb

echo "listen_address='*'" > ~/data/postgresql.conf

echo "host    all             all             0.0.0.0/0            trust" >> /home/vagrant/data/pg_hba.conf
pg_ctl -D /home/vagrant/data/ -l pg.log start
