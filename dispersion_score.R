# AM 2010
# INPUT: instantiation matrix (+1,-1) CSV w. 90% train and 10% test split, target size n
# OUTPUT: matrix with n cols optimizing dispersion score 

args <- commandArgs(TRUE)
print(args)

target_size<-as.integer(args[2])
print("Target size;")
print(target_size)

x<-read.csv(args[1],header=TRUE)
x<-as.matrix(x)

nr_instances<-dim(x)[1]
train_test_border<-as.integer(nr_instances * 0.9)
nr_features<-dim(x)[2]-1
act_index<-dim(x)[2]

print("Checking nr instances > 1...")
if (nr_instances <= 1)
{
    print("FAIL")
    return
}
print("OK")

print("Checking nr features > 1...")
if (nr_features <= 1) 
{
    print("FAIL")
    return
}
print("OK")

features<-c(1:nr_features)
# randomize features
features<-sample(features,length(features))

# select first element
start<-features[1]
features<-features[!features == start]
selected_features<-c(start)

if (target_size>1)
for (count in 2:target_size) {
    min<-Inf
    min_index<-1
    print(count)
    for(i in features) { 
       disp_score_i<-0
       for (j in selected_features) {
            dotp<-(x[1:train_test_border,j]%*%x[1:train_test_border,i])[1,1]
            disp_score_i<-disp_score_i+dotp^2
       }
       dotp<-(x[1:train_test_border,act_index]%*%x[1:train_test_border,i])[1,1]
       disp_score_i<-disp_score_i-length(selected_features)*dotp^2
       if (disp_score_i < min) { 
           min<-disp_score_i
           #print(min)
           min_index<-i
       }
    }
    #print(min)
    #print(min_index)
    selected_features<-append(selected_features,min_index)
    features<-features[!features == min_index]
}

selected_features<-append(selected_features,act_index)
print(selected_features)

outfile<-args[1]
outfile<-paste(outfile,sep="",".disp")
write.table(x[,selected_features],col.names=T,row.names=F,sep=",",outfile)

q(save="no")
